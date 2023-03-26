interface Progress : Container, SingleChild
{
    void SetSize(float width, float height);
    Vec2f getSize();

    void SetProgress(float progress);
    float getProgress();

    void OnChange(EventHandler@ handler);
}

class StandardProgress : Progress
{
    private string text;
    private float progress = 0.0f;
    private Component@ component;
    private Vec2f alignment = Vec2f_zero;
    private Vec2f margin = Vec2f_zero;
    private Vec2f padding = Vec2f_zero;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;

    private EventHandler@[] changeHandlers;

    void SetText(string text)
    {
        this.text = text;
    }

    string getText()
    {
        return text;
    }

    void SetProgress(float progress)
    {
        float prevProgress = this.progress;
        this.progress = Maths::Clamp01(progress);

        if (this.progress != prevProgress)
        {
            for (uint i = 0; i < changeHandlers.size(); i++)
            {
                changeHandlers[i].Handle();
            }
        }
    }

    float getProgress()
    {
        return progress;
    }

    void SetComponent(Component@ component)
    {
        @this.component = component;
    }

    void SetAlignment(float x, float y)
    {
        alignment.x = Maths::Clamp01(x);
        alignment.y = Maths::Clamp01(y);
    }

    void SetMargin(float x, float y)
    {
        margin.x = x;
        margin.y = y;
    }

    Vec2f getMargin()
    {
        return margin;
    }

    void SetPadding(float x, float y)
    {
        padding.x = x;
        padding.y = y;
    }

    Vec2f getPadding()
    {
        return padding;
    }

    void SetSize(float width, float height)
    {
        size.x = width;
        size.y = height;
    }

    Vec2f getSize()
    {
        return size;
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
        return size - padding * 2.0f;
    }

    Vec2f getTrueBounds()
    {
        return size;
    }

    Vec2f getBounds()
    {
        return margin + size + margin;
    }

    Component@ getHoveredComponent()
    {
        return isHovered() ? cast<Component>(this) : null;
    }

    void OnChange(EventHandler@ handler)
    {
        if (handler !is null)
        {
            changeHandlers.push_back(handler);
        }
    }

    private bool isHovered()
    {
        return isMouseInBounds(position, position + size);
    }

    void Update()
    {
        if (component !is null)
        {
            component.Update();
        }
    }

    void Render()
    {
        Vec2f min = position + margin;
        Vec2f max = min + size;

        GUI::DrawProgressBar(min, max, progress);

        if (component !is null)
        {
            Vec2f innerBounds = getInnerBounds();
            Vec2f pos = min + padding + Vec2f(innerBounds.x * alignment.x, innerBounds.y * alignment.y);

            component.SetPosition(pos.x, pos.y);
            component.Render();
        }
    }
}
