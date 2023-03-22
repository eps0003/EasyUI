interface Label : VisibleComponent
{
    void SetText(string text);
    void SetFont(string font);
    void SetColor(SColor color);
    void SetCentered(bool x, bool y);
}

interface AreaLabel : Label
{
    void SetSize(float width, float height);
}

class StandardLabel : Label
{
    private string text;
    private SColor color = color_black;
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

    void SetCentered(bool x, bool y)
    {
        centerX = x;
        centerY = y;
    }

    void SetPosition(float x, float y)
    {
        position = Vec2f(x, y);
    }

    Vec2f getBounds()
    {
        Vec2f dim;
        GUI::GetTextDimensions(text, dim);
        return dim;
    }

    void Render()
    {
        if (text == "") return;

        Vec2f dim;
        GUI::GetTextDimensions(text, dim);

        Vec2f center(
            centerX ? dim.x * 0.5f : 0,
            centerY ? dim.y * 0.5f : 0
        );

        GUI::DrawText(text, position - center, color);
    }
}

class StandardAreaLabel : AreaLabel
{
    private string text;
    private SColor color = color_black;
    private bool centerX = false;
    private bool centerY = false;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;

    StandardAreaLabel()
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

    void SetCentered(bool x, bool y)
    {
        centerX = x;
        centerY = y;
    }

    void SetSize(float width, float height)
    {
        size = Vec2f(width, height);
    }

    void SetPosition(float x, float y)
    {
        position = Vec2f(x, y);
    }

    Vec2f getBounds()
    {
        return size;
    }

    void Render()
    {
        if (text == "") return;

        Vec2f center(
            centerX ? size.x * 0.5f : 0.0f,
            centerY ? size.y * 0.5f : 0.0f
        );

        GUI::DrawText(text, position - center, position - center + size, color, centerX, centerY);
    }
}
