interface Button : Container, SingleChild
{
    void SetSize(float width, float height);
    void Click();

    void OnPress(EventHandler@ handler);
    void OnRelease(EventHandler@ handler);
    void OnClick(EventHandler@ handler);
}

class StandardButton : Button
{
    private EasyUI@ ui;

    private Component@ component;
    private Vec2f alignment = Vec2f_zero;
    private Vec2f margin = Vec2f_zero;
    private Vec2f padding = Vec2f_zero;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private bool pressed = false;

    private EventHandler@[] pressHandlers;
    private EventHandler@[] releaseHandlers;
    private EventHandler@[] clickHandlers;

    StandardButton(EasyUI@ ui)
    {
        @this.ui = ui;
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

    private bool isHovered()
    {
        Vec2f min = position + margin;
        Vec2f max = min + getTrueBounds();
        return isMouseInBounds(min, max);
    }

    Component@ getHoveredComponent()
    {
        return isHovered() ? cast<Component>(this) : null;
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

    void Update()
    {
        CControls@ controls = getControls();

        if (controls.isKeyJustPressed(KEY_LBUTTON) && ui.isComponentHovered(this))
        {
            pressed = true;

            for (uint i = 0; i < pressHandlers.size(); i++)
            {
                pressHandlers[i].Handle();
            }
        }

        if (!controls.isKeyPressed(KEY_LBUTTON) && pressed)
        {
            if (ui.isComponentHovered(this))
            {
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
        Vec2f min = position + margin;
        Vec2f max = min + size;

        if (ui.isComponentHovered(this))
        {
            if (pressed)
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
            if (pressed)
            {
                GUI::DrawButtonHover(min, max);
            }
            else
            {
                GUI::DrawButton(min, max);
            }
        }

        if (component !is null)
        {
            Vec2f innerBounds = getInnerBounds();
            Vec2f pos = min + padding + Vec2f(innerBounds.x * alignment.x, innerBounds.y * alignment.y);

            component.SetPosition(pos.x, pos.y);
            component.Render();
        }
    }
}
