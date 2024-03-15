interface List : Component
{
    void SetSpacing(float x, float y);
    Vec2f getSpacing();

    void SetCellWrap(uint cells);
    uint getCellWrap();

    void SetFlowDirection(FlowDirection direction);
    FlowDirection getFlowDirection();
}

enum FlowDirection
{
    // Top left
    RightDown,
    DownRight,
    // Top right
    LeftDown,
    DownLeft,
    // Bottom left
    RightUp,
    UpRight,
    // Bottom right
    LeftUp,
    UpLeft
}

class StandardList : List, StandardStack
{
    private Vec2f spacing = Vec2f_zero;
    private uint cellWrap = 1;
    private FlowDirection flowDirection = FlowDirection::RightDown;

    private float[] minWidths;
    private float[] minHeights;
    private float[] stretchWidths;
    private float[] stretchHeights;

    void SetSpacing(float x, float y)
    {
        x = Maths::Max(0, x);
        y = Maths::Max(0, y);

        if (spacing.x == x && spacing.y == y) return;

        spacing.x = x;
        spacing.y = y;

        DispatchEvent(Event::Spacing);
        CalculateMinBounds();
    }

    Vec2f getSpacing()
    {
        return spacing;
    }

    void SetCellWrap(uint cellWrap)
    {
        cellWrap = Maths::Max(cellWrap, 1);

        if (this.cellWrap == cellWrap) return;

        this.cellWrap = cellWrap;

        DispatchEvent(Event::CellWrap);
        CalculateMinBounds();
    }

    uint getCellWrap()
    {
        return cellWrap;
    }

    void SetFlowDirection(FlowDirection direction)
    {
        if (flowDirection == direction) return;

        flowDirection = direction;

        DispatchEvent(Event::FlowDirection);
        CalculateMinBounds();
    }

    FlowDirection getFlowDirection()
    {
        return flowDirection;
    }

    private uint getCellX(uint index)
    {
        switch (flowDirection)
        {
            case FlowDirection::RightDown:
            case FlowDirection::RightUp:
                return index % cellWrap;
            case FlowDirection::LeftDown:
            case FlowDirection::LeftUp:
                return cellWrap - 1 - index % cellWrap;
            case FlowDirection::DownRight:
            case FlowDirection::UpRight:
                return index / cellWrap;
            case FlowDirection::DownLeft:
            case FlowDirection::UpLeft:
                return getVisibleColumns() - 1 - index / cellWrap;
        }
        return 0;
    }

    private uint getCellY(uint index)
    {
        switch (flowDirection)
        {
            case FlowDirection::DownRight:
            case FlowDirection::DownLeft:
                return index % cellWrap;
            case FlowDirection::UpRight:
            case FlowDirection::UpLeft:
                return cellWrap - 1 - index % cellWrap;
            case FlowDirection::RightDown:
            case FlowDirection::LeftDown:
                return index / cellWrap;
            case FlowDirection::RightUp:
            case FlowDirection::LeftUp:
                return getVisibleRows() - 1 - index / cellWrap;
        }
        return 0;
    }

    private Vec2f getCellOffset(uint x, uint y)
    {
        Vec2f offset;

        // Add spacing
        offset.x = spacing.x * x;
        offset.y = spacing.y * y;

        // Add cell widths
        for (uint xx = 0; xx < x; xx++)
        {
            offset.x += stretchWidths[xx];
        }

        // Add cell heights
        for (uint yy = 0; yy < y; yy++)
        {
            offset.y += stretchHeights[yy];
        }

        return offset;
    }

    private uint getVisibleRows()
    {
        switch (flowDirection)
        {
            case FlowDirection::RightDown:
            case FlowDirection::RightUp:
            case FlowDirection::LeftDown:
            case FlowDirection::LeftUp:
                return Maths::Ceil(components.size() / float(cellWrap));
            case FlowDirection::DownRight:
            case FlowDirection::DownLeft:
            case FlowDirection::UpRight:
            case FlowDirection::UpLeft:
                return Maths::Min(components.size(), cellWrap);
        }
        return 0;
    }

    private uint getVisibleColumns()
    {
        switch (flowDirection)
        {
            case FlowDirection::RightDown:
            case FlowDirection::RightUp:
            case FlowDirection::LeftDown:
            case FlowDirection::LeftUp:
                return Maths::Min(components.size(), cellWrap);
            case FlowDirection::DownRight:
            case FlowDirection::DownLeft:
            case FlowDirection::UpRight:
            case FlowDirection::UpLeft:
                return Maths::Ceil(components.size() / float(cellWrap));
        }
        return 0;
    }

    Vec2f getMinBounds()
    {
        if (calculateMinBounds)
        {
            calculateMinBounds = false;

            uint visibleRows = getVisibleRows();
            uint visibleColumns = getVisibleColumns();

            // Calculate min widths of columns and heights of rows
            minWidths = array<float>(visibleColumns, 0.0f);
            minHeights = array<float>(visibleRows, 0.0f);

            for (uint i = 0; i < components.size(); i++)
            {
                Vec2f childBounds = components[i].getMinBounds();

                uint x = getCellX(i);
                uint y = getCellY(i);

                if (childBounds.x > minWidths[x])
                {
                    minWidths[x] = childBounds.x;
                }
                if (childBounds.y > minHeights[y])
                {
                    minHeights[y] = childBounds.y;
                }
            }

            // Calculate min bounds
            minBounds.SetZero();

            // Sum column widths and row heights
            for (uint i = 0; i < visibleColumns; i++)
            {
                minBounds.x += minWidths[i];
            }
            for (uint i = 0; i < visibleRows; i++)
            {
                minBounds.y += minHeights[i];
            }

            // Spacing between components
            minBounds.x += (visibleColumns - 1) * spacing.x;
            minBounds.y += (visibleRows - 1) * spacing.y;

            // Margin and padding
            minBounds += (margin + padding) * 2.0f;

            // Calculate stretch widths of columns and heights of rows
            Vec2f desiredCellStretchBounds = getInnerBounds();
            if (components.size() > 1)
            {
                // Remove spacing
                desiredCellStretchBounds.x -= (visibleColumns - 1) * spacing.x;
                desiredCellStretchBounds.y -= (visibleRows - 1) * spacing.y;

                // Divide equally among columns and rows
                desiredCellStretchBounds.x /= visibleColumns;
                desiredCellStretchBounds.y /= visibleRows;
            }

            stretchWidths = array<float>(visibleColumns, desiredCellStretchBounds.x);
            stretchHeights = array<float>(visibleRows, desiredCellStretchBounds.y);

            stretchWidths = distributeExcess(stretchWidths, minWidths);
            stretchHeights = distributeExcess(stretchHeights, minHeights);
        }

        return minBounds;
    }

    Vec2f getStretchBounds(Component@ child)
    {
        // Ensure stretchWidths and stretchHeights are calculated
        getMinBounds();

        for (uint i = 0; i < components.size(); i++)
        {
            Component@ component = components[i];
            if (child !is component) continue;

            uint x = getCellX(i);
            uint y = getCellY(i);

            return Vec2f(stretchWidths[x], stretchHeights[y]);
        }

        return Vec2f_zero;
    }

    void Render()
    {
        Vec2f innerPos = getInnerPosition();

        for (uint i = 0; i < components.size(); i++)
        {
            Component@ component = components[i];

            uint x = getCellX(i);
            uint y = getCellY(i);

            Vec2f childBounds = component.getBounds();
            Vec2f childAlignment = component.getAlignment();
            Vec2f cellBounds(stretchWidths[x], stretchHeights[y]);
            Vec2f boundsDiff = cellBounds - childBounds;
            Vec2f offset = getCellOffset(x, y);

            Vec2f childPos;
            childPos.x = innerPos.x + offset.x + boundsDiff.x * childAlignment.x;
            childPos.y = innerPos.y + offset.y + boundsDiff.y * childAlignment.y;

            component.SetPosition(childPos.x, childPos.y);
            component.Render();
        }
    }
}
