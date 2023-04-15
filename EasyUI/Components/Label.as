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

class StandardLabel : Label, CachedBounds
{
    private string text;
    private string font = "menu";
    private SColor color = color_black;
    private Vec2f position = Vec2f_zero;
    private Vec2f alignment = Vec2f_zero;
    private EventListener@ events = StandardEventListener();

    private Vec2f bounds = Vec2f_zero;
    private bool calculateBounds = true;

    void SetText(string text)
    {
        if (this.text == text) return;

        this.text = text;

        CalculateBounds();
    }

    string getText()
    {
        return text;
    }

    void SetFont(string font)
    {
        if (this.font == font) return;

        this.font = font;

        CalculateBounds();
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
        if (calculateBounds)
        {
            calculateBounds = false;

            GUI::SetFont(font);
            GUI::GetTextDimensions(text, bounds);
        }

        return bounds;
    }

    void CalculateBounds()
    {
        if (calculateBounds) return;

        calculateBounds = true;
        events.DispatchEvent("resize");
    }

    Component@ getHoveredComponent()
    {
        return null;
    }

    Component@ getScrollableComponent()
    {
        return null;
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

    void Update()
    {

    }

    void Render()
    {
        if (text == "") return;

        // The magic values correctly align the text with the bounds
        Vec2f pos;
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
    private Vec2f alignment = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private EventListener@ events = StandardEventListener();

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
        if (size.x == width && size.y == height) return;

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

    Component@ getScrollableComponent()
    {
        return null;
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

    void Update()
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
