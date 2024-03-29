interface Pane : List
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

class StandardPane : Pane, StandardList
{
    private StandardPaneType type = StandardPaneType::Normal;
    private SColor color;
    private bool hasColor = false;

    StandardPane(EasyUI@ ui)
    {
        super(ui);
    }

    StandardPane(EasyUI@ ui, StandardPaneType type)
    {
        super(ui);

        this.type = type;
    }

    StandardPane(EasyUI@ ui, SColor color)
    {
        super(ui);

        this.color = color;
        hasColor = true;
    }

    bool canClick()
    {
        return true;
    }

    void Render()
    {
        if (!isVisible()) return;

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

        StandardList::Render();
    }
}
