interface List : Container, MultiChild
{
    void SetSpacing(float x, float y);
    Vec2f getSpacing();

    void SetAlignment(float x, float y);
    Vec2f getAlignment();

    void SetRows(uint rows);
    uint getRows();

    void SetColumns(uint columns);
    uint getColumns();

    void SetScrollbar(Slider@ scrollbar);
    Slider@ getScrollbar();

    void SetScrollIndex(uint index);
    uint getScrollIndex();
}

class VerticalList : List, CachedBounds
{
    private Component@[] components;
    private Vec2f margin = Vec2f_zero;
    private Vec2f padding = Vec2f_zero;
    private Vec2f alignment = Vec2f_zero;
    private Vec2f spacing = Vec2f_zero;
    private uint rows = 0;
    private uint columns = 1;
    private Vec2f position = Vec2f_zero;
    private Slider@ scrollbar;
    private uint scrollIndex = 0;
    private EventListener@ events = StandardEventListener();
    private EventHandler@ scrollbarResizeHandler;

    // Properties calculated dynamically
    private Vec2f innerBounds = Vec2f_zero;
    private bool calculateBounds = true;
    private float[] columnWidths;
    private float[] rowHeights;

    VerticalList()
    {
        @scrollbarResizeHandler = CachedBoundsHandler(this);
    }

    private uint getTotalRows()
    {
        return Maths::Ceil(components.size() / float(columns));
    }

    private uint getVisibleRows()
    {
        uint totalRows = getTotalRows();
        return (rows > 0 && rows < totalRows) ? rows : totalRows;
    }

    private uint getVisibleColumns()
    {
        return Maths::Min(components.size(), columns);
    }

    private uint getHiddenRows()
    {
        return getTotalRows() - getVisibleRows();
    }

    private uint getVisibleCount()
    {
        uint visibleCount = components.size() - scrollIndex * columns;
        uint maxVisible = getVisibleRows() * columns;
        return Maths::Min(visibleCount, maxVisible);
    }

    private bool isScrollbarVisible()
    {
        return getVisibleRows() != getTotalRows();
    }

    void AddComponent(Component@ component)
    {
        components.push_back(component);

        CalculateBounds();
        component.AddEventListener("resize", CachedBoundsHandler(this));
    }

    Component@[] getComponents()
    {
        return components;
    }

    void SetMargin(float x, float y)
    {
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

    void SetSpacing(float x, float y)
    {
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
        if (this.rows == rows) return;

        this.rows = rows;

        CalculateBounds();
    }

    uint getRows()
    {
        return rows;
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

    void SetScrollbar(Slider@ scrollbar)
    {
        if (this.scrollbar is scrollbar) return;

        if (scrollbar !is null)
        {
            scrollbar.AddEventListener("resize", scrollbarResizeHandler);
        }
        else
        {
            this.scrollbar.RemoveEventListener("resize", scrollbarResizeHandler);
        }

        @this.scrollbar = scrollbar;

        CalculateBounds();
    }

    Slider@ getScrollbar()
    {
        return scrollbar;
    }

    void SetScrollIndex(uint index)
    {
        uint hiddenRows = getHiddenRows();
        uint prevScrollIndex = scrollIndex;
        scrollIndex = Maths::Min(index, hiddenRows);

        if (scrollIndex != prevScrollIndex)
        {
            if (scrollbar !is null)
            {
                scrollbar.SetPercentage(index / Maths::Max(hiddenRows, 1.0f));
            }

            DispatchEvent("scroll");
            CalculateBounds();
        }
    }

    uint getScrollIndex()
    {
        return scrollIndex;
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

    Vec2f getInnerBounds()
    {
        if (calculateBounds)
        {
            calculateBounds = false;

            rowHeights.clear();
            columnWidths.clear();

            uint visibleRows = getVisibleRows();
            uint visibleColumns = getVisibleColumns();

            // Spacing between components
            innerBounds.x = Maths::Max(visibleColumns - 1, 0) * spacing.x;
            innerBounds.y = Maths::Max(visibleRows - 1, 0) * spacing.y;

            // Component widths
            for (uint i = 0; i < visibleColumns; i++)
            {
                float width = getColumnInnerWidth(i);
                columnWidths.push_back(width);
                innerBounds.x += width;
            }

            // Component heights
            for (uint i = 0; i < visibleRows; i++)
            {
                float height = getRowInnerHeight(scrollIndex + i);
                rowHeights.push_back(height);
                innerBounds.y += height;
            }
        }

        return innerBounds;
    }

    Vec2f getTrueBounds()
    {
        float scrollWidth = scrollbar !is null ? scrollbar.getSize().x : 0.0f;
        return padding + getInnerBounds() + padding + Vec2f(scrollWidth, 0.0f);
    }

    Vec2f getBounds()
    {
        return margin + getTrueBounds() + margin;
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

    private bool isHovered()
    {
        Vec2f min = position + margin;
        Vec2f max = min + getTrueBounds();
        return isMouseInBounds(min, max);
    }

    Component@ getHoveredComponent()
    {
        if (isHovered())
        {
            if (scrollbar !is null)
            {
                Component@ hovered = scrollbar.getHoveredComponent();
                if (hovered !is null)
                {
                    return hovered;
                }
            }

            uint startIndex = scrollIndex * columns;
            uint endIndex = startIndex + getVisibleCount();

            for (int i = endIndex - 1; i >= startIndex; i--)
            {
                Component@ component = components[i];
                if (component is null) continue;

                Component@ hovered = component.getHoveredComponent();
                if (hovered is null) continue;

                return hovered;
            }
        }
        return null;
    }

    Component@ getScrollableComponent()
    {
        if (isHovered())
        {
            uint startIndex = scrollIndex * columns;
            uint endIndex = startIndex + getVisibleCount();

            for (int i = endIndex - 1; i >= startIndex; i--)
            {
                Component@ component = components[i];
                if (component is null) continue;

                Component@ scrollable = component.getScrollableComponent();
                if (scrollable is null) continue;

                return scrollable;
            }

            return cast<Component>(this);
        }
        return null;
    }

    private float getColumnInnerWidth(float column)
    {
        float width = 0.0f;

        uint startIndex = scrollIndex * columns + column;
        uint endIndex = scrollIndex * columns + getVisibleCount();

        for (uint i = startIndex; i < endIndex; i += columns)
        {
            Component@ component = components[i];
            if (component is null) continue;

            float childWidth = component.getBounds().x;
            if (childWidth <= width) continue;

            width = childWidth;
        }

        return width;
    }

    private float getRowInnerHeight(float row)
    {
        float height = 0.0f;

        uint startIndex = row * columns;
        uint endIndex = Maths::Min(startIndex + columns, components.size());

        for (uint i = startIndex; i < endIndex; i++)
        {
            Component@ component = components[i];
            if (component is null) continue;

            float childHeight = component.getBounds().y;
            if (childHeight <= height) continue;

            height = childHeight;
        }

        return height;
    }

    void Update()
    {
        uint startIndex = scrollIndex * columns;
        uint endIndex = startIndex + getVisibleCount();

        Vec2f min = position + margin;
        Vec2f max = min + getTrueBounds();

        if (ui.canScroll(this))
        {
            uint scrollIndex = getScrollIndex();
            CControls@ controls = getControls();

            if (controls.mouseScrollDown)
            {
                scrollIndex++;
            }
            if (controls.mouseScrollUp && scrollIndex > 0)
            {
                scrollIndex--;
            }

            SetScrollIndex(scrollIndex);
        }

        for (int i = endIndex - 1; i >= startIndex; i--)
        {
            Component@ component = components[i];
            if (component is null) continue;

            component.Update();
        }

        if (scrollbar !is null)
        {
            scrollbar.Update();
        }
    }

    void Render()
    {
        if (scrollbar !is null && isScrollbarVisible())
        {
            SetScrollIndex((getHiddenRows() + 1) * scrollbar.getPercentage());

            Vec2f trueBounds = getTrueBounds();
            float scrollWidth = scrollbar.getSize().x;
            float scrollHeight = trueBounds.y;
            float scrollPosX = position.x + margin.x + trueBounds.x - scrollWidth;
            scrollbar.SetPosition(scrollPosX, position.y);
            scrollbar.SetSize(scrollWidth, scrollHeight);
            scrollbar.SetHandleSize(scrollHeight * getVisibleRows() / getTotalRows());
            scrollbar.Render();
        }

        Vec2f offset = Vec2f_zero;
        Vec2f innerPos = position + margin + padding;

        uint startIndex = scrollIndex * columns;
        uint endIndex = startIndex + getVisibleCount();

        for (uint i = startIndex; i < endIndex; i++)
        {
            Component@ component = components[i];
            Vec2f childBounds = component !is null
                ? component.getBounds()
                : Vec2f_zero;

            uint x = i % columns;
            uint y = (i - startIndex) / columns;
            Vec2f cellBounds(columnWidths[x], rowHeights[y]);

            if (x == 0)
            {
                offset.x = 0.0f;
            }

            if (component !is null)
            {
                Vec2f alignmentOffset = cellBounds - childBounds;
                alignmentOffset *= alignment;
                Vec2f pos = innerPos + alignmentOffset + offset;

                component.SetPosition(pos.x, pos.y);
                component.Render();
            }

            offset.x += cellBounds.x + spacing.x;
            if (x == columns - 1)
            {
                offset.y += cellBounds.y + spacing.y;
            }
        }
    }
}

// class HorizontalList : List
// {
//     private Component@[] components;
//     private Vec2f margin = Vec2f_zero;
//     private Vec2f padding = Vec2f_zero;
//     private float spacing = 0.0f;
//     private float alignment = 0.0f;
//     private uint rows = 1;
//     private uint columns = 0;
//     private Vec2f position = Vec2f_zero;

//     void AddComponent(Component@ component)
//     {
//         components.push_back(component);
//     }

//     void SetMargin(float x, float y)
//     {
//         margin.x = x;
//         margin.y = y;
//     }

//     void SetPadding(float x, float y)
//     {
//         padding.x = x;
//         padding.y = y;
//     }

//     void SetSpacing(float spacing)
//     {
//         this.spacing = spacing;
//     }

//     void SetAlignment(float x)
//     {
//         alignment = Maths::Clamp01(x);
//     }

//     void SetRows(uint rows)
//     {
//         this.rows = rows;
//     }

//     void SetColumns(uint columns)
//     {
//         this.columns = Maths::Max(columns, 1);
//     }

//     void SetPosition(float x, float y)
//     {
//         position.x = x;
//         position.y = y;
//     }

//     private Vec2f getInnerBounds()
//     {
//         uint n = components.size();
//         if (n == 0) return Vec2f_zero;

//         Vec2f bounds(0.0f, spacing * (n - 1));
//         for (uint i = 0; i < n; i++)
//         {
//             Vec2f childBounds = components[i].getBounds();
//             if (childBounds.y > bounds.y)
//             {
//                 bounds.y = childBounds.y;
//             }
//             bounds.x += childBounds.x;
//         }
//         return bounds;
//     }

//     Vec2f getTrueBounds()
//     {
//         return padding + getInnerBounds() + padding;
//     }

//     Vec2f getBounds()
//     {
//         return margin + getTrueBounds() + margin;
//     }

//     void Update()
//     {
//         for (int i = components.size() - 1; i >= 0; i--)
//         {
//             Component@ component = components[i];
//             if (component is null) continue;

//             component.Update();
//         }
//     }

//     void Render()
//     {
//         float offset = 0.0f;
//         float height = getBounds().y;

//         uint n = Maths::Min(rows, components.size());

//         for (uint i = 0; i < n; i++)
//         {
//             Component@ component = components[i];
//             Vec2f bounds = component.getBounds();
//             float heightDiff = height - bounds.y;

//             component.SetPosition(position.x + offset, position.y + heightDiff * alignment);
//             component.Render();

//             offset += bounds.x + spacing;
//         }
//     }
// }
