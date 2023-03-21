#include "Component.as"
#include "Label.as"

interface Button : VisibleComponent, InteractableComponent
{
    void SetSize(float width, float height);
    void Click();
    void OnClick(ButtonClickHandler@ listener);
}

interface TextButton : Button
{
    void SetText(string text);
    void SetColor(SColor color);
}

interface ButtonClickHandler
{
    void Handle();
}

class StandardTextButton : TextButton
{
    private ButtonClickHandler@[] listeners;
    private string text;
    private SColor color;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private bool pressed = false;

    void Click()
    {
        for (uint i = 0; i < listeners.size(); i++)
        {
            listeners[i].Handle();
        }
    }

    void OnClick(ButtonClickHandler@ listener)
    {
        listeners.push_back(listener);
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
        size = Vec2f(width, height);
    }

    Vec2f getSize()
    {
        return size;
    }

    void SetPosition(float x, float y)
    {
        position = Vec2f(x, y);
    }

    Vec2f getBounds()
    {
        return size;
    }

    private bool isHovered()
    {
        Vec2f mouse = getControls().getInterpMouseScreenPos();
        return (
            mouse.x >= position.x &&
            mouse.y >= position.y &&
            mouse.x <= position.x + size.x &&
            mouse.y <= position.y + size.y
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
        if (isHovered() && pressed)
        {
            GUI::DrawSunkenPane(position, position + size);
        }
        else
        {
            GUI::DrawPane(position, position + size);
        }
        GUI::DrawTextCentered(text, position + size * 0.5f, color);
    }
}
