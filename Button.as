interface Button : VisibleComponent, InteractableComponent
{
    void SetSize(float width, float height);
    void Click();
    void OnClick(EventHandler@ handler);
}

interface TextButton : Button
{
    void SetText(string text);
    void SetColor(SColor color);
}

class StandardTextButton : TextButton
{
    private EventHandler@[] clickHandlers;
    private string text;
    private SColor color;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private bool pressed = false;

    void Click()
    {
        for (uint i = 0; i < clickHandlers.size(); i++)
        {
            clickHandlers[i].Handle();
        }
    }

    void OnClick(EventHandler@ handler)
    {
        clickHandlers.push_back(handler);
    }

    void SetText(string text)
    {
        this.text = text;
    }

    void SetColor(SColor color)
    {
        this.color = color;
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

    private bool isHovered()
    {
        Vec2f mousePos = getControls().getInterpMouseScreenPos();
        return (
            mousePos.x >= position.x &&
            mousePos.y >= position.y &&
            mousePos.x <= position.x + size.x &&
            mousePos.y <= position.y + size.y
        );
    }

    void Update()
    {
        CControls@ controls = getControls();

        if (controls.isKeyJustPressed(KEY_LBUTTON) && isHovered())
        {
            pressed = true;
        }

        if (!controls.isKeyPressed(KEY_LBUTTON) && pressed)
        {
            if (isHovered())
            {
                Click();
            }

            pressed = false;
        }
    }

    void Render()
    {
        if (isHovered())
        {
            if (pressed)
            {
                GUI::DrawButtonPressed(position, position + size);
            }
            else
            {
                GUI::DrawButtonHover(position, position + size);
            }
        }
        else
        {
            if (pressed)
            {
                GUI::DrawButtonHover(position, position + size);
            }
            else
            {
                GUI::DrawButton(position, position + size);
            }
        }

        GUI::DrawTextCentered(text, position + size * 0.5f, color);
    }
}
