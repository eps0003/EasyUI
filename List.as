interface List : Container, MultiChild
{
    void SetSpacing(float spacing);
    void SetAlignment(float x, float y);
    void SetRows(uint rows);
    void SetColumns(uint columns);
}

class VerticalList : List
{
    private Component@[] components;
    private Vec2f margin = Vec2f_zero;
    private Vec2f padding = Vec2f_zero;
    private float spacing = 0.0f;
    private Vec2f alignment = Vec2f_zero;
    private uint rows = 0;
    private uint columns = 1;
    private Vec2f position = Vec2f_zero;
    private Slider@ scrollbar = StandardVerticalSlider();

    void AddComponent(Component@ component)
    {
        components.push_back(component);
    }

    void SetMargin(float x, float y)
    {
        margin.x = x;
        margin.y = y;
    }

    void SetPadding(float x, float y)
    {
        padding.x = x;
        padding.y = y;
    }

    void SetSpacing(float spacing)
    {
        this.spacing = spacing;
    }

    void SetAlignment(float x, float y)
    {
        alignment.x = Maths::Clamp01(x);
        alignment.y = Maths::Clamp01(y);
    }

    void SetRows(uint rows)
    {
        this.rows = rows;
    }

    void SetColumns(uint columns)
    {
        this.columns = Maths::Max(columns, 1);
    }

    void SetPosition(float x, float y)
    {
        position.x = x;
        position.y = y;
    }

    private Vec2f getInnerBounds()
    {
        uint visibleRows = getVisibleRows();
        uint visibleColumns = getVisibleColumns();
        uint rowIndex = getRowIndex();

        Vec2f bounds = Vec2f_zero;

        for (uint i = 0; i < visibleColumns; i++)
        {
            bounds.x += getColumnInnerWidth(i);
        }

        for (uint i = 0; i < visibleRows; i++)
        {
            uint index = rowIndex + i;
            bounds.y += getRowInnerHeight(index);
        }

        return bounds + Vec2f(Maths::Max(visibleColumns - 1, 1), Maths::Max(visibleRows - 1, 1)) * spacing;
    }

    Vec2f getTrueBounds()
    {
        return padding + getInnerBounds() + padding;
    }

    Vec2f getBounds()
    {
        return margin + getTrueBounds() + margin;
    }

    private Vec2f[] getCellBounds()
    {
        uint visibleRows = getVisibleRows();
        uint visibleColumns = getVisibleColumns();
        uint rowIndex = getRowIndex();

        float[] widths = array<float>(visibleColumns, 0.0f);
        float[] heights = array<float>(visibleRows, 0.0f);
        Vec2f[] bounds = array<Vec2f>(visibleColumns * visibleRows, Vec2f_zero);

        for (uint i = 0; i < visibleColumns; i++)
        {
            widths[i] = getColumnInnerWidth(i);
        }

        for (uint i = 0; i < visibleRows; i++)
        {
            heights[i] = getRowInnerHeight(rowIndex + i);
        }

        for (uint y = 0; y < visibleRows; y++)
        for (uint x = 0; x < visibleColumns; x++)
        {
            uint index = y * columns + x;
            bounds[index].x = widths[x];
            bounds[index].y = heights[y];
        }

        return bounds;
    }

    private float getColumnInnerWidth(float column)
    {
        float width = 0.0f;

        uint startIndex = getRowIndex() * columns + column;
        uint endIndex = Maths::Min(startIndex + getVisibleCount(), components.size());

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

    private uint getTotalRows()
    {
        return Maths::Ceil(components.size() / float(columns));
    }

    private uint getVisibleRows()
    {
        uint totalRows = getTotalRows();
        return rows > 0 && rows < totalRows ? rows : totalRows;
    }

    private uint getVisibleColumns()
    {
        return Maths::Min(components.size(), columns);
    }

    private uint getVisibleCount()
    {
        return Maths::Min(getVisibleRows() * getVisibleColumns(), components.size());
    }

    private uint getRowIndex()
    {
        uint hiddenRows = getTotalRows() - getVisibleRows();
        return Maths::Min((hiddenRows + 1) * scrollbar.getPercentage(), hiddenRows);
    }

    void Update()
    {
        for (int i = components.size() - 1; i >= 0; i--)
        {
            Component@ component = components[i];
            if (component is null) continue;

            component.Update();
        }

        scrollbar.Update();
    }

    void Render()
    {
        uint totalCount = components.size();
        uint visibleCount = getVisibleCount();
        uint rowIndex = getRowIndex();

        Vec2f offset = Vec2f_zero;
        Vec2f innerPos = position + margin + padding;

        Vec2f[] bounds = getCellBounds();

        uint startIndex = rowIndex * columns;
        uint endIndex = Maths::Min(startIndex + visibleCount, components.size());

        for (uint i = startIndex; i < endIndex; i++)
        {
            Component@ component = components[i];
            Vec2f childBounds = component !is null
                ? component.getBounds()
                : Vec2f_zero;

            uint columnIndex = i % columns;
            if (columnIndex == 0)
            {
                offset.x = 0.0f;
            }

            if (component !is null)
            {
                Vec2f alignmentOffset = bounds[i - startIndex] - childBounds;
                alignmentOffset *= alignment;
                Vec2f pos = innerPos + alignmentOffset + offset;

                component.SetPosition(pos.x, pos.y);
                component.Render();
            }

            offset.x += bounds[i - startIndex].x + spacing;
            if (columnIndex == columns - 1)
            {
                offset.y += bounds[i - startIndex].y + spacing;
            }
        }

        if (totalCount != visibleCount)
        {
            Vec2f bounds = getTrueBounds();
            float scrollHeight = bounds.y;
            float scrollPosX = innerPos.x + bounds.x + (padding.x + margin.x) * 2.0f;
            scrollbar.SetPosition(scrollPosX, position.y);
            scrollbar.SetSize(30, scrollHeight);
            scrollbar.SetHandleSize(scrollHeight * visibleCount / Maths::Max(totalCount, 1.0f));
            scrollbar.Render();
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
