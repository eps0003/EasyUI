interface Toggle : Button
{
    void SetChecked(bool checked);
    bool isChecked();
}

class StandardToggle : Toggle
{
    private EasyUI@ ui;
    private Button@ button;

    private bool pressed = false;
    private bool checked = false;

    StandardToggle(EasyUI@ ui)
    {
        @this.ui = ui;
        @button = StandardButton(ui);
    }

    void SetComponent(Component@ component)
    {
        button.SetComponent(component);
    }

    bool isPressed()
    {
        return pressed;
    }

    void SetMargin(float x, float y)
    {
        button.SetMargin(x, y);
    }

    Vec2f getMargin()
    {
        return button.getMargin();
    }

    void SetPadding(float x, float y)
    {
        button.SetPadding(x, y);
    }

    Vec2f getPadding()
    {
        return button.getPadding();
    }

    void SetAlignment(float x, float y)
    {
        button.SetAlignment(x, y);
    }

    Vec2f getAlignment()
    {
        return button.getAlignment();
    }

    void SetSize(float width, float height)
    {
        button.SetSize(width, height);
    }

    Vec2f getSize()
    {
        return button.getSize();
    }

    void SetPosition(float x, float y)
    {
        button.SetPosition(x, y);
    }

    Vec2f getPosition()
    {
        return button.getPosition();
    }

    Vec2f getInnerBounds()
    {
        return button.getInnerBounds();
    }

    Vec2f getTrueBounds()
    {
        return button.getTrueBounds();
    }

    Vec2f getBounds()
    {
        return button.getBounds();
    }

    bool isHovered()
    {
        return button.isHovered();
    }

    bool isInteracting()
    {
        return button.isInteracting();
    }

    bool canClick()
    {
        return button.canClick();
    }

    bool canScroll()
    {
        return button.canScroll();
    }

    Component@[] getComponents()
    {
        return button.getComponents();
    }

    void SetChecked(bool checked)
    {
        bool wasChecked = this.checked;
        this.checked = checked;

        if (this.checked != wasChecked)
        {
            DispatchEvent("change");
        }
    }

    bool isChecked()
    {
        return checked;
    }

    void AddEventListener(string type, EventHandler@ handler)
    {
        button.AddEventListener(type, handler);
    }

    void RemoveEventListener(string type, EventHandler@ handler)
    {
        button.RemoveEventListener(type, handler);
    }

    void DispatchEvent(string type)
    {
        button.DispatchEvent(type);
    }

    void Update()
    {
        CControls@ controls = getControls();

        if (controls.isKeyJustPressed(KEY_LBUTTON) && ui.canClick(this))
        {
            pressed = true;
            DispatchEvent("press");
        }

        if (!controls.isKeyPressed(KEY_LBUTTON) && pressed)
        {
            if (ui.canClick(this))
            {
                SetChecked(!checked);
                DispatchEvent("click");
            }

            pressed = false;
            DispatchEvent("release");
        }

        // Component@ component = getComponent();
        // if (component !is null)
        // {
        //     component.Update();
        // }
    }

    void Render()
    {
        Vec2f min = getPosition() + getMargin();
        Vec2f max = min + getSize();

        if (ui.canClick(this))
        {
            if (pressed)
            {
                if (checked)
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
                if (checked)
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
            if (pressed)
            {
                if (checked)
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
                if (checked)
                {
                    GUI::DrawButtonPressed(min, max);
                }
                else
                {
                    GUI::DrawButton(min, max);
                }
            }
        }

        // Component@ component = getComponent();
        // if (component !is null)
        // {
        //     Vec2f padding = getPadding();
        //     Vec2f innerBounds = getInnerBounds();
        //     Vec2f alignment = getAlignment();

        //     Vec2f pos;
        //     pos.x = min.x + padding.x + innerBounds.x * alignment.x;
        //     pos.y = min.y + padding.y + innerBounds.y * alignment.y;

        //     component.SetPosition(pos.x, pos.y);
        //     component.Render();
        // }
    }
}
