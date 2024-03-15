interface Button : List
{
    bool isPressed();
}

class StandardButton : Button, StandardList
{
    private EasyUI@ ui;
    private bool wasHovering = false;

    StandardButton()
    {
        error("Initialized StandardButton using the default constructor. Use StandardButton(EasyUI@ ui) instead.");
        printTrace();

        super();

        @ui = EasyUI();
    }

    StandardButton(EasyUI@ ui)
    {
        super();

        @this.ui = ui;

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

        bool hovering = ui.isHovering() && isHovering();
        bool pressed = isPressed();

        if (!wasHovering && hovering && !pressed)
        {
            Sound::Play("select.ogg");
        }

        wasHovering = hovering;

        StandardList::Render();
    }
}
