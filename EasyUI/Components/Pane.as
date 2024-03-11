interface Pane : Stack
{

}

enum StandardPaneType
{
    Normal,
    Sunken,
    Framed,
    Window,
    Bubble
}

class StandardPane : Pane, StandardStack
{
    private StandardPaneType type = StandardPaneType::Normal;
    private SColor color;
    private bool hasColor = false;

    StandardPane(StandardPaneType type)
    {
        this.type = type;
    }

    StandardPane(SColor color)
    {
        this.color = color;
        hasColor = true;
    }

    bool canClick()
    {
        return true;
    }

    void Render()
    {
        Vec2f min = getTruePosition();
        Vec2f max = min + getTrueBounds();

        switch (type)
        {
            case StandardPaneType::Normal:
                hasColor
                    ? GUI::DrawPane(min, max, color)
                    : GUI::DrawPane(min, max);
                break;
            case StandardPaneType::Sunken:
                GUI::DrawSunkenPane(min, max);
                break;
            case StandardPaneType::Framed:
                GUI::DrawFramedPane(min, max);
                break;
            case StandardPaneType::Window:
                GUI::DrawWindow(min, max);
                break;
            case StandardPaneType::Bubble:
                GUI::DrawBubble(min, max);
                break;
            default:
                GUI::DrawPane(min, max);
                break;
        }

        StandardStack::Render();
    }
}
