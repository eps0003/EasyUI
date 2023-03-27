interface ToggleButton : Button
{
    void SetChecked(bool checked);
    bool isChecked();
}

class StandardToggleButton : ToggleButton
{
    private EasyUI@ ui;

    private Component@ component;
    private Vec2f alignment = Vec2f_zero;
    private Vec2f margin = Vec2f_zero;
    private Vec2f padding = Vec2f_zero;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private EventListener@ events = StandardEventListener();

    private bool checked = false;
    private bool pressed = false;

    StandardToggleButton(EasyUI@ ui)
    {
        @this.ui = ui;
    }

    void SetComponent(Component@ component)
    {
        @this.component = component;
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

    void SetAlignment(float x, float y)
    {
        alignment.x = Maths::Clamp01(x);
        alignment.y = Maths::Clamp01(y);
    }

    Vec2f getAlignment()
    {
        return alignment;
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

    List@ getHoveredList()
    {
        return null;
    }

    void SetChecked(bool checked)
    {
        bool wasChecked = this.checked;
        this.checked = checked;

        if (this.checked != wasChecked)
        {
            events.DispatchEvent("change");
        }
    }

    bool isChecked()
    {
        return checked;
    }

    void AddEventListener(string type, EventHandler@ handler)
    {
        events.AddEventListener(type, handler);
    }

    void RemoveEventListener(string type, EventHandler@ handler)
    {
        events.RemoveEventListener(type, handler);
    }

    void DispatchEvent(string type)
    {
        events.DispatchEvent(type);
    }

    private bool isHovered()
    {
        Vec2f min = position + margin;
        Vec2f max = min + getTrueBounds();
        return isMouseInBounds(min, max);
    }

    void Update()
    {
        CControls@ controls = getControls();

        if (controls.isKeyJustPressed(KEY_LBUTTON) && ui.isComponentHovered(this))
        {
            pressed = true;
            events.DispatchEvent("press");
        }

        if (!controls.isKeyPressed(KEY_LBUTTON) && pressed)
        {
            if (ui.isComponentHovered(this))
            {
                events.DispatchEvent("click");
            }

            pressed = false;
            events.DispatchEvent("release");
        }

        if (component !is null)
        {
            component.Update();
        }
    }

    void PreRender()
    {
        if (component !is null)
        {
            component.PreRender();
        }
    }

    void Render()
    {
        Vec2f min = position + margin;
        Vec2f max = min + size;

        if (ui.isComponentHovered(this))
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

        if (component !is null)
        {
            Vec2f innerBounds = getInnerBounds();
            Vec2f pos;

            pos.x = min.x + padding.x + innerBounds.x * alignment.x;
            pos.y = min.y + padding.y + innerBounds.y * alignment.y;

            component.SetPosition(pos.x, pos.y);
            component.Render();
        }
    }
}
