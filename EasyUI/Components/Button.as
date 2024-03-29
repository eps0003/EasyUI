interface Button : List
{
    bool isPressed();
}

class StandardButton : Button, StandardList
{
    StandardButton()
    {
        error("Initialized StandardButton using the default constructor. Use StandardButton(EasyUI@ ui) instead.");
        printTrace();

        super(EasyUI());
    }

    StandardButton(EasyUI@ ui)
    {
        super(ui);

        AddEventListener(Event::Click, PlaySoundHandler("menuclick.ogg"));
    }

    bool isPressed()
    {
        return ui.isInteractingWith(this);
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

        if (ui.canClick(this))
        {
            if (isPressed())
            {
                GUI::DrawButtonPressed(min, max);
            }
            else
            {
                GUI::DrawButtonHover(min, max);
            }
        }
        else
        {
            if (isPressed())
            {
                GUI::DrawButtonHover(min, max);
            }
            else
            {
                GUI::DrawButton(min, max);
            }
        }

        StandardList::Render();
    }
}
