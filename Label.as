#include "Component.as"

interface Label : VisibleComponent
{
    void SetText(string text);
    void SetFont(string font);
    void SetColor(SColor color);
    void SetWidth(float width);
    void SetCentered(bool x, bool y);
}

class StandardLabel : Label
{
    private string text;
    private SColor color = color_black;
    private float width = 0.0f;
    private bool centerX = false;
    private bool centerY = false;
    private Vec2f position = Vec2f_zero;

    StandardLabel()
    {
        GUI::SetFont("menu");
    }

    void SetText(string text)
    {
        this.text = text;
    }

    void SetFont(string font)
    {
        if (!GUI::isFontLoaded(font))
        {
            font = "menu";
        }

        GUI::SetFont(font);
    }

    void SetColor(SColor color)
    {
        this.color = color;
    }

    void SetWidth(float width)
    {
        this.width = width;
    }

    void SetCentered(bool x, bool y)
    {
        centerX = x;
        centerY = y;
    }

    void SetPosition(float x, float y)
    {
        position = Vec2f(x, y);
    }

    void Render()
    {
        if (text == "") return;

        Vec2f dim;
        GUI::GetTextDimensions(text, dim);

        if (width > 0)
        {
            Vec2f center(
                centerX ? width * 0.5f : 0,
                centerY ? dim.y * 0.5f : 0
            );

            GUI::DrawText(text, position - center, position - center + Vec2f(width, 0), color, false, false);
        }
        else
        {
            Vec2f center(
                centerX ? dim.x * 0.5f : 0,
                centerY ? dim.y * 0.5f : 0
            );

            GUI::DrawText(text, position - center, color);
        }
    }
}
