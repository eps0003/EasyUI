interface List : Component
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
        component.AddEventListener(Event::MinSize, CachedBoundsHandler(this));
    }

    void SetParent(Component@ parent)
    {
        if (this.parent is parent) return;

        @this.parent = parent;

        CalculateBounds();
    }

    Component@ getParent()
    {
        return parent;
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

    Vec2f getMinBounds()
    {
        if (calculateBounds)
        {
            calculateBounds = false;
            minBounds.SetZero();

            uint visibleRows = getVisibleRows();
            uint visibleColumns = getVisibleColumns();

            rowHeights = array<float>(visibleRows, 0.0f);
            columnWidths = array<float>(visibleColumns, 0.0f);

            // Calculate largest column widths and row heights
            for (uint y = 0; y < visibleRows; y++)
            for (uint x = 0; x < visibleColumns; x++)
            {
                uint index = y * visibleColumns + x;
                if (index >= components.size()) break;

                Component@ component = components[index];
                Vec2f childBounds = component.getMinBounds();

                if (childBounds.x > columnWidths[x])
                {
                    columnWidths[x] = childBounds.x;
                }
                if (childBounds.y > rowHeights[y])
                {
                    rowHeights[y] = childBounds.y;
                }
            }

            // Sum column widths and row heights
            for (uint i = 0; i < visibleColumns; i++)
            {
                minBounds.x += columnWidths[i];
            }
            for (uint i = 0; i < visibleRows; i++)
            {
                minBounds.y += rowHeights[i];
            }

            // Spacing between components
            if (visibleColumns > 1)
            {
                minBounds.x += (visibleColumns - 1) * spacing.x;
            }
            if (visibleRows > 1)
            {
                minBounds.y += (visibleRows - 1) * spacing.y;
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

    Vec2f getStretchBounds(Component@ child)
    {
        return getInnerBounds();
    }

    void CalculateBounds()
    {
        if (calculateBounds) return;

        calculateBounds = true;

        DispatchEvent("resize");
    }

    void AddEventListener(Event type, EventHandler@ handler)
    {
        events.AddEventListener(type, handler);
    }

    void RemoveEventListener(Event type, EventHandler@ handler)
    {
        events.RemoveEventListener(type, handler);
    }

    void DispatchEvent(Event type)
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

class StandardHorizontalList : HorizontalList
{
    private Component@ parent;
    private Component@[] components;

    private Vec2f margin = Vec2f_zero;
    private Vec2f padding = Vec2f_zero;
    private Vec2f spacing = Vec2f_zero;
    private Vec2f alignment = Vec2f_zero;
    private Vec2f stretch = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private uint rows = 1;

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
        component.AddEventListener(Event::MinSize, CachedBoundsHandler(this));
    }

    void SetParent(Component@ parent)
    {
        if (this.parent is parent) return;

        @this.parent = parent;

        CalculateBounds();
    }

    Component@ getParent()
    {
        return parent;
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

    void SetRows(uint rows)
    {
        rows = Maths::Max(rows, 1);

        if (this.rows == rows) return;

        this.rows = rows;

        CalculateBounds();
    }

    uint getRows()
    {
        return rows;
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
        return Maths::Min(components.size(), rows);
    }

    private uint getVisibleColumns()
    {
        return Maths::Ceil(components.size() / float(rows));
    }

    Vec2f getMinBounds()
    {
        if (calculateBounds)
        {
            calculateBounds = false;
            minBounds.SetZero();

            uint visibleRows = getVisibleRows();
            uint visibleColumns = getVisibleColumns();

            rowHeights = array<float>(visibleRows, 0.0f);
            columnWidths = array<float>(visibleColumns, 0.0f);

            // Calculate largest column widths and row heights
            for (uint x = 0; x < visibleColumns; x++)
            for (uint y = 0; y < visibleRows; y++)
            {
                uint index = x * visibleRows + y;
                if (index >= components.size()) break;

                Component@ component = components[index];
                Vec2f childBounds = component.getMinBounds();

                if (childBounds.x > columnWidths[x])
                {
                    columnWidths[x] = childBounds.x;
                }
                if (childBounds.y > rowHeights[y])
                {
                    rowHeights[y] = childBounds.y;
                }
            }

            // Sum column widths and row heights
            for (uint i = 0; i < visibleColumns; i++)
            {
                minBounds.x += columnWidths[i];
            }
            for (uint i = 0; i < visibleRows; i++)
            {
                minBounds.y += rowHeights[i];
            }

            // Spacing between components
            if (visibleColumns > 1)
            {
                minBounds.x += (visibleColumns - 1) * spacing.x;
            }
            if (visibleRows > 1)
            {
                minBounds.y += (visibleRows - 1) * spacing.y;
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

    Vec2f getStretchBounds(Component@ child)
    {
        return getInnerBounds();
    }

    void CalculateBounds()
    {
        if (calculateBounds) return;

        calculateBounds = true;

        DispatchEvent("resize");
    }

    void AddEventListener(Event type, EventHandler@ handler)
    {
        events.AddEventListener(type, handler);
    }

    void RemoveEventListener(Event type, EventHandler@ handler)
    {
        events.RemoveEventListener(type, handler);
    }

    void DispatchEvent(Event type)
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

        for (uint i = 0; i < components.size(); i++)
        {
            Component@ component = components[i];

            uint x = i / rows;
            uint y = i % rows;

            if (y == 0)
            {
                offset.y = 0.0f;
            }

            Vec2f childBounds = component.getBounds();
            Vec2f cellBounds(columnWidths[x], rowHeights[y]);
            Vec2f boundsDiff = cellBounds - childBounds;

            Vec2f childPos = offset;
            childPos.x += innerPos.x + boundsDiff.x * alignment.x;
            childPos.y += innerPos.y + boundsDiff.y * alignment.y;

            component.SetPosition(childPos.x, childPos.y);
            component.Render();

            offset.y += cellBounds.y + spacing.y;
            if (y == rows - 1)
            {
                offset.x += cellBounds.x + spacing.x;
            }
        }
    }
}
