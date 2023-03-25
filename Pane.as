interface Pane : Container, SingleChild
{

}

enum StandardPaneType
{
    Normal,
    Sunken,
    Framed
}

class StandardPane : Pane
{
    private Component@ component;
    private Vec2f alignment = Vec2f_zero;
    private Vec2f margin = Vec2f_zero;
    private Vec2f padding = Vec2f_zero;
    private StandardPaneType type = StandardPaneType::Normal;
    private Vec2f position = Vec2f_zero;

    StandardPane(StandardPaneType type)
    {
        this.type = type;
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

    void SetPadding(float x, float y)
    {
        padding.x = x;
        padding.y = y;
    }

    void SetPosition(float x, float y)
    {
        position.x = x;
        position.y = y;
    }

    Vec2f getInnerBounds()
    {
        Vec2f componentSize = component !is null
            ? component.getBounds()
            : Vec2f_zero;
        return componentSize;
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
        if (component !is null)
        {
            component.Update();
        }
    }

    void Render()
    {
        if (component is null) return;

        Vec2f innerBounds = getInnerBounds();
        Vec2f min = position + margin;
        Vec2f max = min + padding + innerBounds + padding;
        Vec2f innerPos = min + padding +  Vec2f(innerBounds.x * alignment.x, innerBounds.y * alignment.y);

        switch (type)
        {
            case StandardPaneType::Normal:
                GUI::DrawPane(min, max);
                break;
            case StandardPaneType::Sunken:
                GUI::DrawSunkenPane(min, max);
                break;
            case StandardPaneType::Framed:
                GUI::DrawFramedPane(min, max);
                break;
            default:
                GUI::DrawPane(min, max);
                break;
        }

        component.SetPosition(innerPos.x, innerPos.y);
        component.Render();
    }
}
