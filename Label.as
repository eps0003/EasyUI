interface Label : Component
{
    void SetText(string text);
    string getText();

    void SetFont(string font);
    string getFont();

    void SetColor(SColor color);
    SColor getColor();

    void SetAlignment(float x, float y);
    Vec2f getAlignment();
}

interface AreaLabel : Label
{
    void SetSize(float width, float height);
    Vec2f getSize();
}

class StandardLabel : Label
{
    private string text;
    private string font = "menu";
    private SColor color = color_black;
    private Vec2f position = Vec2f_zero;
    private Vec2f alignment = Vec2f_zero;

    void SetText(string text)
    {
        this.text = text;
    }

    string getText()
    {
        return text;
    }

    void SetFont(string font)
    {
        this.font = font;
    }

    string getFont()
    {
        return font;
    }

    void SetColor(SColor color)
    {
        this.color = color;
    }

    SColor getColor()
    {
        return color;
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

    void SetPosition(float x, float y)
    {
        position.x = x;
        position.y = y;
    }

    Vec2f getPosition()
    {
        return position;
    }

    Vec2f getBounds()
    {
        Vec2f dim;
        GUI::GetTextDimensions(text, dim);
        return dim;
    }

    Component@ getHoveredComponent()
    {
        return null;
    }

    void Update()
    {

    }

    void PreRender()
    {

    }

    void Render()
    {
        if (text == "") return;

        Vec2f bounds = getBounds();
        Vec2f pos;

        // The magic values correctly align the text with the bounds
        pos.x = position.x - bounds.x * alignment.x - 2;
        pos.y = position.x - bounds.y * alignment.y - 1;

        GUI::SetFont(font);
        GUI::DrawText(text, pos, color);
    }
}

class StandardAreaLabel : AreaLabel
{
    private string text;
    private string font = "menu";
    private SColor color = color_black;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private Vec2f alignment = Vec2f_zero;

    void SetText(string text)
    {
        this.text = text;
    }

    string getText()
    {
        return text;
    }

    void SetFont(string font)
    {
        this.font = font;
    }

    string getFont()
    {
        return font;
    }

    void SetColor(SColor color)
    {
        this.color = color;
    }

    SColor getColor()
    {
        return color;
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

    void SetAlignment(float x, float y)
    {
        alignment.x = Maths::Clamp01(x);
        alignment.y = Maths::Clamp01(y);
    }

    Vec2f getAlignment()
    {
        return alignment;
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

    Vec2f getBounds()
    {
        return size;
    }

    Component@ getHoveredComponent()
    {
        return null;
    }

    void Update()
    {

    }

    void PreRender()
    {

    }

    void Render()
    {
        if (text == "") return;

        Vec2f pos;
        pos.x = position.x - size.x * alignment.x;
        pos.y = position.y - size.y * alignment.y;

        GUI::SetFont(font);
        GUI::DrawText(text, pos, pos + size, color, false, false);
    }
}
