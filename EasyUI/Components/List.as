interface List : Stack
{
    void SetSpacing(float x, float y);
    Vec2f getSpacing();
}

interface VerticalList : List
{
    void SetColumns(uint columns);
    uint getColumns();
}

interface HorizontalList : List
{
    void SetRows(uint rows);
    uint getRows();
}

class StandardVerticalList : VerticalList, StandardStack
{
    private Vec2f spacing = Vec2f_zero;
    private uint columns = 1;

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

    void SetColumns(uint columns)
    {
        columns = Maths::Max(columns, 1);

        if (this.columns == columns) return;

        this.columns = columns;

        DispatchEvent(Event::Columns);
        CalculateMinBounds();
    }

    uint getColumns()
    {
        return columns;
    }

    private uint getVisibleRows()
    {
        return Maths::Ceil(components.size() / float(columns));
    }

    private uint getVisibleColumns()
    {
        return Maths::Min(components.size(), columns);
    }

    private Vec2f getTotalStretchBounds()
    {
        Vec2f stretchBounds = parent !is null
            ? parent.getStretchBounds(this)
            : getDriver().getScreenDimensions() - position;
        stretchBounds *= stretchRatio;
        return stretchBounds;
    }

    private Vec2f getDesiredCellStretchBounds()
    {
        uint visibleRows = getVisibleRows();
        uint visibleColumns = getVisibleColumns();

        // Stretch to fill the parent or the screen
        Vec2f stretchBounds = parent !is null
            ? parent.getStretchBounds(this)
            : getDriver().getScreenDimensions() - position;
        stretchBounds *= stretchRatio;

        // Remove spacing
        stretchBounds.x -= (visibleColumns - 1) * spacing.x;
        stretchBounds.y -= (visibleRows - 1) * spacing.y;

        // Divide equally
        stretchBounds.x /= visibleColumns;
        stretchBounds.y /= visibleRows;

        return stretchBounds;
    }

    Vec2f getMinBounds()
    {
        if (calculateMinBounds)
        {
            calculateMinBounds = false;

            uint visibleRows = getVisibleRows();
            uint visibleColumns = getVisibleColumns();
            Vec2f desiredCellStretchBounds = getDesiredCellStretchBounds();

            // Calculate min widths of columns and heights of rows
            minWidths = array<float>(visibleColumns, 0.0f);
            minHeights = array<float>(visibleRows, 0.0f);

            for (uint y = 0; y < visibleRows; y++)
            for (uint x = 0; x < visibleColumns; x++)
            {
                uint index = y * visibleColumns + x;
                if (index >= components.size()) break;

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

            uint x = i % columns;
            uint y = i / columns;

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

            uint x = i % columns;
            uint y = i / columns;

            Vec2f childBounds = component.getBounds();
            Vec2f childAlignment = component.getAlignment();
            Vec2f cellBounds(stretchWidths[x], stretchHeights[y]);
            Vec2f boundsDiff = cellBounds - childBounds;

            Vec2f childPos = offset;
            childPos.x += innerPos.x + boundsDiff.x * childAlignment.x;
            childPos.y += innerPos.y + boundsDiff.y * childAlignment.y;

            component.SetPosition(childPos.x, childPos.y);
            component.Render();

            if (x < columns - 1)
            {
                offset.x += cellBounds.x + spacing.x;
            }
            else
            {
                offset.x = 0.0f;
                offset.y += cellBounds.y + spacing.y;
            }
        }
    }
}

class StandardHorizontalList : HorizontalList, StandardStack
{
    private Vec2f spacing = Vec2f_zero;
    private uint rows = 1;

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

    void SetRows(uint rows)
    {
        rows = Maths::Max(rows, 1);

        if (this.rows == rows) return;

        this.rows = rows;

        DispatchEvent(Event::Rows);
        CalculateMinBounds();
    }

    uint getRows()
    {
        return rows;
    }

    private uint getVisibleRows()
    {
        return Maths::Ceil(components.size() / float(rows));
    }

    private uint getVisibleColumns()
    {
        return Maths::Min(components.size(), rows);
    }

    private Vec2f getTotalStretchBounds()
    {
        Vec2f stretchBounds = parent !is null
            ? parent.getStretchBounds(this)
            : getDriver().getScreenDimensions() - position;
        stretchBounds *= stretchRatio;
        return stretchBounds;
    }

    private Vec2f getDesiredCellStretchBounds()
    {
        uint visibleRows = getVisibleRows();
        uint visibleColumns = getVisibleColumns();

        // Stretch to fill the parent or the screen
        Vec2f stretchBounds = parent !is null
            ? parent.getStretchBounds(this)
            : getDriver().getScreenDimensions() - position;
        stretchBounds *= stretchRatio;

        // Remove spacing
        stretchBounds.x -= (visibleColumns - 1) * spacing.x;
        stretchBounds.y -= (visibleRows - 1) * spacing.y;

        // Divide equally
        stretchBounds.x /= visibleColumns;
        stretchBounds.y /= visibleRows;

        return stretchBounds;
    }

    Vec2f getMinBounds()
    {
        if (calculateMinBounds)
        {
            calculateMinBounds = false;

            uint visibleRows = getVisibleRows();
            uint visibleColumns = getVisibleColumns();
            Vec2f desiredCellStretchBounds = getDesiredCellStretchBounds();

            // Calculate min widths of columns and heights of rows
            minWidths = array<float>(visibleColumns, 0.0f);
            minHeights = array<float>(visibleRows, 0.0f);

            for (uint x = 0; x < visibleColumns; x++)
            for (uint y = 0; y < visibleRows; y++)
            {
                uint index = x * visibleRows + y;
                if (index >= components.size()) break;

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

            uint x = i / rows;
            uint y = i % rows;

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

            uint x = i / rows;
            uint y = i % rows;

            Vec2f childBounds = component.getBounds();
            Vec2f childAlignment = component.getAlignment();
            Vec2f cellBounds(stretchWidths[x], stretchHeights[y]);
            Vec2f boundsDiff = cellBounds - childBounds;

            Vec2f childPos = offset;
            childPos.x += innerPos.x + boundsDiff.x * childAlignment.x;
            childPos.y += innerPos.y + boundsDiff.y * childAlignment.y;

            component.SetPosition(childPos.x, childPos.y);
            component.Render();

            if (y < rows - 1)
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
