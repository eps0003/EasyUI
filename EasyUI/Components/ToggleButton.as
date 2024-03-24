interface Toggle : Button
{
    void SetChecked(bool checked);
    bool isChecked();
}

class StandardToggle : Toggle, StandardButton
{
    private bool checked = false;

    StandardToggle()
    {
        error("Initialized StandardToggle using the default constructor. Use StandardToggle(EasyUI@ ui) instead.");
        printTrace();

        super(EasyUI());

        AddEventListener(Event::Click, ToggleClickHandler(this));
    }

    StandardToggle(EasyUI@ ui)
    {
        super(ui);

        AddEventListener(Event::Click, ToggleClickHandler(this));
    }

    bool isPressed()
    {
        return ui.isInteractingWith(this);
    }

    void SetChecked(bool checked)
    {
        if (this.checked == checked) return;

        this.checked = checked;

        DispatchEvent(Event::Checked);
    }

    bool isChecked()
    {
        return checked;
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
                if (isChecked())
                {
                    GUI::DrawButtonPressed(min, max);
                }
                else
                {
                    GUI::DrawButtonPressed(min, max);
                }
            }
            else
            {
                if (isChecked())
                {
                    GUI::DrawSunkenPane(min, max);
                }
                else
                {
                    GUI::DrawButtonHover(min, max);
                }
            }
        }
        else
        {
            if (isPressed())
            {
                if (isChecked())
                {
                    GUI::DrawSunkenPane(min, max);
                }
                else
                {
                    GUI::DrawButtonHover(min, max);
                }
            }
            else
            {
                if (isChecked())
                {
                    GUI::DrawButtonPressed(min, max);
                }
                else
                {
                    GUI::DrawButton(min, max);
                }
            }
        }

        StandardStack::Render();
    }
}
