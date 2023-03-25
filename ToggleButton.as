interface ToggleButton : Button
{
    void SetChecked(bool checked);
}

class StandardToggleButton : ToggleButton
{
    private Component@ component;
    private Vec2f alignment = Vec2f_zero;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private bool checked = false;
    private bool pressed = false;

    private EventHandler@[] pressHandlers;
    private EventHandler@[] releaseHandlers;
    private EventHandler@[] clickHandlers;

    void SetComponent(Component@ component)
    {
        @this.component = component;
    }

    void SetAlignment(float x, float y)
    {
        alignment.x = Maths::Clamp01(x);
        alignment.y = Maths::Clamp01(y);
    }

    void SetChecked(bool checked)
    {
        this.checked = checked;
    }

    void SetSize(float width, float height)
    {
        size.x = width;
        size.y = height;
    }

    void SetPosition(float x, float y)
    {
        position.x = x;
        position.y = y;
    }

    Vec2f getBounds()
    {
        return size;
    }

    void OnPress(EventHandler@ handler)
    {
        if (handler !is null)
        {
            pressHandlers.push_back(handler);
        }
    }

    void OnRelease(EventHandler@ handler)
    {
        if (handler !is null)
        {
            releaseHandlers.push_back(handler);
        }
    }

    void OnClick(EventHandler@ handler)
    {
        if (handler !is null)
        {
            clickHandlers.push_back(handler);
        }
    }

    void Click()
    {
        for (uint i = 0; i < clickHandlers.size(); i++)
        {
            clickHandlers[i].Handle();
        }
    }

    private bool isHovered()
    {
        return isMouseInBounds(position, position + size);
    }

    void Update()
    {
        CControls@ controls = getControls();

        if (controls.isKeyJustPressed(KEY_LBUTTON) && isHovered())
        {
            pressed = true;

            for (uint i = 0; i < pressHandlers.size(); i++)
            {
                pressHandlers[i].Handle();
            }
        }

        if (!controls.isKeyPressed(KEY_LBUTTON) && pressed)
        {
            if (isHovered())
            {
                checked = !checked;
                Click();
            }

            pressed = false;

            for (uint i = 0; i < releaseHandlers.size(); i++)
            {
                releaseHandlers[i].Handle();
            }
        }

        if (component !is null)
        {
            component.Update();
        }
    }

    void Render()
    {
        if (isHovered())
        {
            if (pressed)
            {
                if (checked)
                {
                    GUI::DrawButtonPressed(position, position + size);
                }
                else
                {
                    GUI::DrawButtonPressed(position, position + size);
                }
            }
            else
            {
                if (checked)
                {
                    GUI::DrawButtonHover(position, position + size);
                }
                else
                {
                    GUI::DrawSunkenPane(position, position + size);
                }
            }
        }
        else
        {
            if (pressed)
            {
                if (checked)
                {
                    GUI::DrawButtonHover(position, position + size);
                }
                else
                {
                    GUI::DrawSunkenPane(position, position + size);
                }
            }
            else
            {
                if (checked)
                {
                    GUI::DrawButton(position, position + size);
                }
                else
                {
                    GUI::DrawButtonPressed(position, position + size);
                }
            }
        }

        if (component !is null)
        {
            Vec2f pos = position + Vec2f(size.x * alignment.x, size.y * alignment.y);
            component.SetPosition(pos.x, pos.y);
            component.Render();
        }
    }
}
