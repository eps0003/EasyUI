interface List : MultiContainer
{
    void SetSpacing(float spacing);
    void SetAlignment(float x);
    void SetRows(uint rows);
    void SetColumns(uint columns);
}

class VerticalList : List
{
    private Component@[] components;
    private Vec2f margin = Vec2f_zero;
    private Vec2f padding = Vec2f_zero;
    private float spacing = 0.0f;
    private float alignment = 0.0f;
    private uint rows = 0;
    private uint columns = 1;
    private Vec2f position = Vec2f_zero;
    private Slider@ scrollbar;

    VerticalList()
    {
        @scrollbar = VerticalSlider();
    }

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

    void SetAlignment(float x)
    {
        alignment = Maths::Clamp01(x);
    }

    void SetRows(uint rows)
    {
        this.rows = rows;
    }

    void SetColumns(uint columns)
    {
        this.columns = columns;
    }

    void SetPosition(float x, float y)
    {
        position.x = x;
        position.y = y;
    }

    private Vec2f getInnerBounds()
    {
        uint n = getVisibleCount();
        if (n == 0) return Vec2f_zero;

        uint index = getScrollIndex();

        Vec2f bounds(0.0f, spacing * (n - 1));
        for (uint i = 0; i < n; i++)
        {
            Vec2f childBounds = components[index + i].getBounds();
            if (childBounds.x > bounds.x)
            {
                bounds.x = childBounds.x;
            }
            bounds.y += childBounds.y;
        }
        return bounds;
    }

    Vec2f getTrueBounds()
    {
        return padding + getInnerBounds() + padding;
    }

    Vec2f getBounds()
    {
        return margin + getTrueBounds() + margin;
    }

    private uint getScrollIndex()
    {
        uint totalCount = components.size();
        uint visibleCount = getVisibleCount();
        uint hiddenCount = totalCount - visibleCount;
        return Maths::Min((hiddenCount + 1) * scrollbar.getPercentage(), hiddenCount);
    }

    private uint getVisibleCount()
    {
        return Maths::Min(rows, components.size());
    }

    void Update()
    {
        for (int i = components.size() - 1; i >= 0; i--)
        {
            components[i].Update();
        }

        scrollbar.Update();
    }

    void Render()
    {
        uint totalCount = components.size();
        uint visibleCount = getVisibleCount();
        uint index = getScrollIndex();

        float offset = 0.0f;
        Vec2f innerBounds = getInnerBounds();
        Vec2f innerPos = position + margin + padding;

        for (uint i = 0; i < visibleCount; i++)
        {
            Component@ component = components[index + i];
            Vec2f bounds = component.getBounds();
            float widthDiff = innerBounds.x - bounds.x;

            component.SetPosition(innerPos.x + widthDiff * alignment, innerPos.y + offset);
            component.Render();

            offset += bounds.y + spacing;
        }

        if (totalCount != visibleCount)
        {
            float scrollHeight = getTrueBounds().y;
            float scrollPosX = innerPos.x + innerBounds.x + (padding.x + margin.x) * 2.0f;
            scrollbar.SetPosition(scrollPosX, position.y);
            scrollbar.SetSize(30, scrollHeight);
            scrollbar.SetHandleSize(scrollHeight * visibleCount / Maths::Max(totalCount, 1.0f));
            scrollbar.Render();
        }
    }
}

class HorizontalList : List
{
    private Component@[] components;
    private Vec2f margin = Vec2f_zero;
    private Vec2f padding = Vec2f_zero;
    private float spacing = 0.0f;
    private float alignment = 0.0f;
    private uint rows = 1;
    private uint columns = 0;
    private Vec2f position = Vec2f_zero;

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

    void SetAlignment(float x)
    {
        alignment = Maths::Clamp01(x);
    }

    void SetRows(uint rows)
    {
        this.rows = rows;
    }

    void SetColumns(uint columns)
    {
        this.columns = columns;
    }

    void SetPosition(float x, float y)
    {
        position.x = x;
        position.y = y;
    }

    private Vec2f getInnerBounds()
    {
        uint n = components.size();
        if (n == 0) return Vec2f_zero;

        Vec2f bounds(0.0f, spacing * (n - 1));
        for (uint i = 0; i < n; i++)
        {
            Vec2f childBounds = components[i].getBounds();
            if (childBounds.y > bounds.y)
            {
                bounds.y = childBounds.y;
            }
            bounds.x += childBounds.x;
        }
        return bounds;
    }

    Vec2f getTrueBounds()
    {
        return padding + getInnerBounds() + padding;
    }

    Vec2f getBounds()
    {
        return margin + getTrueBounds() + margin;
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
        float offset = 0.0f;
        float height = getBounds().y;

        uint n = Maths::Min(rows, components.size());

        for (uint i = 0; i < n; i++)
        {
            Component@ component = components[i];
            Vec2f bounds = component.getBounds();
            float heightDiff = height - bounds.y;

            component.SetPosition(position.x + offset, position.y + heightDiff * alignment);
            component.Render();

            offset += bounds.x + spacing;
        }
    }
}
