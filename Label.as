interface Label : Component
{
    void SetText(string text);
    void SetFont(string font);
    void SetColor(SColor color);
    void SetAlignment(float x, float y);
}

interface AreaLabel : Label
{
    void SetSize(float width, float height);
}

class StandardLabel : Label
{
    private string text;
    private string font = "menu";
    private SColor color = color_black;
    private bool centerX = false;
    private bool centerY = false;
    private Vec2f position = Vec2f_zero;
    private Vec2f alignment = Vec2f_zero;

    void SetText(string text)
    {
        this.text = text;
    }

    void SetFont(string font)
    {
        this.font = GUI::isFontLoaded(font) ? font : "menu";
    }

    void SetColor(SColor color)
    {
        this.color = color;
    }

    void SetAlignment(float x, float y)
    {
        alignment.x = Maths::Clamp01(x);
        alignment.y = Maths::Clamp01(y);
    }

    void SetPosition(float x, float y)
    {
        position.x = x;
        position.y = y;
    }

    Vec2f getBounds()
    {
        Vec2f dim;
        GUI::GetTextDimensions(text, dim);
        return dim;
    }

    void Update()
    {

    }

    void Render()
    {
        if (text == "") return;

        // The hardcoded offset correctly aligns text with the bounds
        Vec2f bounds = getBounds();
        Vec2f pos = position - Vec2f(bounds.x * alignment.x, bounds.y * alignment.y) - Vec2f(2, 1);

        GUI::SetFont(font);
        GUI::DrawText(text, pos, color);
    }
}

class StandardAreaLabel : AreaLabel
{
    private string text;
    private string font = "menu";
    private SColor color = color_black;
    private bool centerX = false;
    private bool centerY = false;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private Vec2f alignment = Vec2f_zero;

    void SetText(string text)
    {
        this.text = text;
    }

    void SetFont(string font)
    {
        this.font = GUI::isFontLoaded(font) ? font : "menu";
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

    void SetAlignment(float x, float y)
    {
        alignment.x = Maths::Clamp01(x);
        alignment.y = Maths::Clamp01(y);
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

    void Update()
    {

    }

    void Render()
    {
        if (text == "") return;

        Vec2f pos = position - Vec2f(size.x * alignment.x, size.y * alignment.y);

        GUI::SetFont(font);
        GUI::DrawText(text, pos, pos + size, color, false, false);
    }
}
