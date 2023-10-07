interface List : Container, MultiChild
{
    void SetSpacing(float x, float y);
    Vec2f getSpacing();
}

interface VerticalList : List
{
    void SetColumns(uint columns);
    uint getColumns();
}

class StandardVerticalList : VerticalList
{
    private Component@ parent;
    private Component@[] components;

    private Vec2f margin = Vec2f_zero;
    private Vec2f padding = Vec2f_zero;
    private Vec2f spacing = Vec2f_zero;
    private Vec2f alignment = Vec2f_zero;
    private Vec2f stretch = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private uint columns = 1;

    private EventDispatcher@ events = StandardEventDispatcher();

    private Vec2f minBounds = Vec2f_zero;
    private bool calculateBounds = true;
    private float[] columnWidths;
    private float[] rowHeights;

    void AddComponent(Component@ component)
    {
        if (component is null) return;

        components.push_back(component);
        component.SetParent(this);

        CalculateBounds();
        component.AddEventListener("resize", CachedBoundsHandler(this));
    }

    void SetParent(Component@ parent)
    {
        if (this.parent is parent) return;

        @this.parent = parent;

        CalculateBounds();
    }

    void SetMargin(float x, float y)
    {
        x = Maths::Max(0, x);
        y = Maths::Max(0, y);

        if (margin.x == x && margin.y == y) return;

        margin.x = x;
        margin.y = y;

        CalculateBounds();
    }

    Vec2f getMargin()
    {
        return margin;
    }

    void SetPadding(float x, float y)
    {
        x = Maths::Max(0, x);
        y = Maths::Max(0, y);

        if (padding.x == x && padding.y == y) return;

        padding.x = x;
        padding.y = y;

        CalculateBounds();
    }

    Vec2f getPadding()
    {
        return padding;
    }

    void SetAlignment(float x, float y)
    {
        alignment.x = Maths::Clamp01(x);
        alignment.y = Maths::Clamp01(y);
    }

    Vec2f getAlignment()
    {
        return alignment;
    }

    void SetStretchRatio(float x, float y)
    {
        stretch.x = Maths::Clamp01(x);
        stretch.y = Maths::Clamp01(y);
    }

    Vec2f getStretchRatio()
    {
        return stretch;
    }

    void SetSpacing(float x, float y)
    {
        x = Maths::Max(0, x);
        y = Maths::Max(0, y);

        if (spacing.x == x && spacing.y == y) return;

        spacing.x = x;
        spacing.y = y;

        CalculateBounds();
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

        CalculateBounds();
    }

    uint getColumns()
    {
        return columns;
    }

    void SetPosition(float x, float y)
    {
        position.x = x;
        position.y = y;
    }

    Vec2f getPosition()
    {
        return position;
    }

    Vec2f getTruePosition()
    {
        return getPosition() + margin;
    }

    Vec2f getInnerPosition()
    {
        return getTruePosition() + padding;
    }

    private uint getVisibleRows()
    {
        return Maths::Ceil(components.size() / float(columns));
    }

    private uint getVisibleColumns()
    {
        return Maths::Min(components.size(), columns);
    }

    private float getColumnMinWidth(float column)
    {
        float width = 0.0f;

        uint startIndex = column;
        uint endIndex = components.size();

        for (uint i = startIndex; i < endIndex; i += columns)
        {
            Component@ component = components[i];

            float childWidth = component.getMinBounds().x;
            if (childWidth <= width) continue;

            width = childWidth;
        }

        return width;
    }

    private float getRowMinHeight(float row)
    {
        float height = 0.0f;

        uint startIndex = row * columns;
        uint endIndex = Maths::Min(startIndex + columns, components.size());

        for (uint i = startIndex; i < endIndex; i++)
        {
            Component@ component = components[i];

            float childHeight = component.getMinBounds().y;
            if (childHeight <= height) continue;

            height = childHeight;
        }

        return height;
    }

    Vec2f getMinBounds()
    {
        if (calculateBounds)
        {
            calculateBounds = false;
            minBounds.SetZero();

            rowHeights.clear();
            columnWidths.clear();

            uint visibleRows = getVisibleRows();
            uint visibleColumns = getVisibleColumns();

            // Spacing between components
            if (visibleColumns > 1)
            {
                minBounds.x += (visibleColumns - 1) * spacing.x;
            }

            if (visibleRows > 1)
            {
                minBounds.y += (visibleRows - 1) * spacing.y;
            }

            // Component widths
            for (uint i = 0; i < visibleColumns; i++)
            {
                float width = getColumnMinWidth(i);
                columnWidths.push_back(width);
                minBounds.x += width;
            }

            // Component heights
            for (uint i = 0; i < visibleRows; i++)
            {
                float height = getRowMinHeight(i);
                rowHeights.push_back(height);
                minBounds.y += height;
            }

            minBounds += (margin + padding) * 2.0f;
        }

        return minBounds;
    }

    Vec2f getBounds()
    {
        return getMinBounds();
    }

    Vec2f getTrueBounds()
    {
        return getBounds() - margin * 2.0f;
    }

    Vec2f getInnerBounds()
    {
        return getTrueBounds() - padding * 2.0f;
    }

    void CalculateBounds()
    {
        if (calculateBounds) return;

        calculateBounds = true;

        DispatchEvent("resize");
    }

    void AddEventListener(string type, EventHandler@ handler)
    {
        events.AddEventListener(type, handler);
    }

    void RemoveEventListener(string type, EventHandler@ handler)
    {
        events.RemoveEventListener(type, handler);
    }

    void DispatchEvent(string type)
    {
        events.DispatchEvent(type);
    }

    bool isHovering()
    {
        return ::isHovering(this);
    }

    bool canClick()
    {
        return false;
    }

    bool canScroll()
    {
        return false;
    }

    Component@[] getComponents()
    {
        return components;
    }

    void Update()
    {
        for (int i = components.size() - 1; i >= 0; i--)
        {
            components[i].Update();
        }
    }

    void Render()
    {
        Vec2f offset = Vec2f_zero;
        Vec2f innerPos = getInnerPosition();
        Vec2f innerBounds = getInnerBounds();

        for (uint i = 0; i < components.size(); i++)
        {
            Component@ component = components[i];

            uint x = i % columns;
            uint y = i / columns;

            if (x == 0)
            {
                offset.x = 0.0f;
            }

            Vec2f childBounds = component.getBounds();
            Vec2f cellBounds(columnWidths[x], rowHeights[y]);
            Vec2f boundsDiff = cellBounds - childBounds;

            Vec2f childPos = offset;
            childPos.x += innerPos.x + boundsDiff.x * alignment.x;
            childPos.y += innerPos.y + boundsDiff.y * alignment.y;

            component.SetPosition(childPos.x, childPos.y);
            component.Render();

            offset.x += cellBounds.x + spacing.x;
            if (x == columns - 1)
            {
                offset.y += cellBounds.y + spacing.y;
            }
        }
    }
}
