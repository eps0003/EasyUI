interface List : Stack
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
    Vertical,
    Horizontal
}

class StandardList : List, StandardStack
{
    private Vec2f spacing = Vec2f_zero;
    private uint cellWrap = 1;
    private FlowDirection flowDirection = FlowDirection::Horizontal;

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

    uint getCellX(uint index)
    {
        return flowDirection == FlowDirection::Horizontal
            ? index % cellWrap
            : index / cellWrap;
    }

    uint getCellY(uint index)
    {
        return flowDirection == FlowDirection::Vertical
            ? index % cellWrap
            : index / cellWrap;
    }

    private uint getVisibleRows()
    {
        return flowDirection == FlowDirection::Horizontal
            ? Maths::Ceil(components.size() / float(cellWrap))
            : Maths::Min(components.size(), cellWrap);
    }

    private uint getVisibleColumns()
    {
        return flowDirection == FlowDirection::Vertical
            ? Maths::Ceil(components.size() / float(cellWrap))
            : Maths::Min(components.size(), cellWrap);
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

            for (uint x = 0; x < visibleColumns; x++)
            for (uint y = 0; y < visibleRows; y++)
            {
                uint index = flowDirection == FlowDirection::Horizontal
                    ? y * visibleColumns + x
                    : x * visibleRows + y;
                if (index >= components.size()) continue;

                Vec2f childBounds = components[index].getMinBounds();
                if (childBounds.x > minWidths[x])
                {
                    minWidths[x] = childBounds.x;
                }
                if (childBounds.y > minHeights[y])
                {
                    minHeights[y] = childBounds.y;
                }
            }

            // Calculate stretch widths of columns and heights of rows
            Vec2f desiredCellStretchBounds = getInnerBounds();

            // Remove spacing
            desiredCellStretchBounds.x -= (visibleColumns - 1) * spacing.x;
            desiredCellStretchBounds.y -= (visibleRows - 1) * spacing.y;

            // Divide equally among columns and rows
            desiredCellStretchBounds.x /= visibleColumns;
            desiredCellStretchBounds.y /= visibleRows;

            stretchWidths = array<float>(visibleColumns, desiredCellStretchBounds.x);
            stretchHeights = array<float>(visibleRows, desiredCellStretchBounds.y);

            stretchWidths = distributeExcess(stretchWidths, minWidths);
            stretchHeights = distributeExcess(stretchHeights, minHeights);

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
        Vec2f offset = Vec2f_zero;
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

            Vec2f childPos = offset;
            childPos.x += innerPos.x + boundsDiff.x * childAlignment.x;
            childPos.y += innerPos.y + boundsDiff.y * childAlignment.y;

            component.SetPosition(childPos.x, childPos.y);
            component.Render();

            if (flowDirection == FlowDirection::Horizontal)
            {
                if (x < cellWrap - 1)
                {
                    offset.x += cellBounds.x + spacing.x;
                }
                else
                {
                    offset.x = 0.0f;
                    offset.y += cellBounds.y + spacing.y;
                }
            }
            else
            {
                if (y < cellWrap - 1)
                {
                    offset.y += cellBounds.y + spacing.y;
                }
                else
                {
                    offset.y = 0.0f;
                    offset.x += cellBounds.x + spacing.x;
                }
            }
        }
    }
}
