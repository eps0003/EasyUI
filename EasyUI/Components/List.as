interface List : Component
{
    void SetSpacing(float x, float y);
    Vec2f getSpacing();

    void SetCellWrap(uint cells);
    uint getCellWrap();

    void SetFlowDirection(FlowDirection direction);
    FlowDirection getFlowDirection();

    void SetColumnSizes(float[] sizes);
    float[] getColumnSizes();

    void SetRowSizes(float[] sizes);
    float[] getRowSizes();
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
    private float[] columnSizes;
    private float[] rowSizes;

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

        CalculateMinBounds();
        DispatchEvent(Event::Spacing);
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

        CalculateMinBounds();
        DispatchEvent(Event::CellWrap);
    }

    uint getCellWrap()
    {
        return cellWrap;
    }

    void SetFlowDirection(FlowDirection direction)
    {
        if (flowDirection == direction) return;

        flowDirection = direction;

        CalculateMinBounds();
        DispatchEvent(Event::FlowDirection);
    }

    FlowDirection getFlowDirection()
    {
        return flowDirection;
    }

    void SetColumnSizes(float[] sizes)
    {
        columnSizes = sizes;
    }

    float[] getColumnSizes()
    {
        return columnSizes;
    }

    void SetRowSizes(float[] sizes)
    {
        rowSizes = sizes;
    }

    float[] getRowSizes()
    {
        return rowSizes;
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
            minBounds.x += Maths::Max(visibleColumns - 1, 0) * spacing.x;
            minBounds.y += Maths::Max(visibleRows - 1, 0) * spacing.y;

            // Add padding and margin while enforcing minimum size
            minBounds.x = Maths::Max(minBounds.x + padding.x * 2.0f, minSize.x) + margin.x * 2.0f;
            minBounds.y = Maths::Max(minBounds.y + padding.y * 2.0f, minSize.y) + margin.y * 2.0f;
        }

        return minBounds;
    }

    Vec2f getStretchBounds(Component@ child)
    {
        uint visibleRows = getVisibleRows();
        uint visibleColumns = getVisibleColumns();

        stretchWidths = array<float>(visibleColumns, 0.0f);
        stretchHeights = array<float>(visibleRows, 0.0f);

        if (components.size() > 0)
        {
            Vec2f availableStretchBounds = getInnerBounds();
            availableStretchBounds.x -= (visibleColumns - 1) * spacing.x;
            availableStretchBounds.y -= (visibleRows - 1) * spacing.y;

            float columnSizesSum = 0.0f;
            for (uint i = 0; i < columnSizes.size() && i < visibleColumns; i++)
            {
                columnSizesSum += columnSizes[i];
            }

            float rowSizesSum = 0.0f;
            for (uint i = 0; i < rowSizes.size() && i < visibleRows; i++)
            {
                rowSizesSum += rowSizes[i];
            }

            for (uint i = 0; i < visibleColumns; i++)
            {
                float size = i < columnSizes.size() ? columnSizes[i] : 0;
                stretchWidths[i] = columnSizesSum > 0.0f
                    ? availableStretchBounds.x * size / columnSizesSum
                    : availableStretchBounds.x / visibleColumns;
            }

            for (uint i = 0; i < visibleRows; i++)
            {
                float size = i < rowSizes.size() ? rowSizes[i] : 0;
                stretchHeights[i] = rowSizesSum > 0.0f
                    ? availableStretchBounds.y * size / rowSizesSum
                    : availableStretchBounds.y / visibleRows;
            }
        }

        stretchWidths = distributeExcess(stretchWidths, minWidths);
        stretchHeights = distributeExcess(stretchHeights, minHeights);

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
