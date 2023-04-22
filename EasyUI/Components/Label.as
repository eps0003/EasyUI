interface Label : Component
{
    void SetText(string text);
    string getText();

    void SetFont(string font);
    string getFont();

    void SetColor(SColor color);
    SColor getColor();
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
    private EventDispatcher@ events = StandardEventDispatcher();

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
        DispatchEvent("resize");
    }

    bool isHovered()
    {
        return isMouseInBounds(position, position + bounds);
    }

    bool canClick()
    {
        return false;
    }

    bool canScroll()
    {
        return false;
    }

    Component@[] getComponents()
    {
        Component@[] components;
        return components;
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

        // The magic values correctly align the text within the bounds
        GUI::SetFont(font);
        GUI::DrawText(text, position - Vec2f(3, 1), color);
    }
}

class StandardAreaLabel : AreaLabel
{
    private string text;
    private string font = "menu";
    private SColor color = color_black;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private EventDispatcher@ events = StandardEventDispatcher();

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

        DispatchEvent("resize");
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

    Vec2f getBounds()
    {
        return size;
    }

    bool isHovered()
    {
        return isMouseInBounds(position, position + size);
    }

    bool canClick()
    {
        return false;
    }

    bool canScroll()
    {
        return false;
    }

    Component@[] getComponents()
    {
        Component@[] components;
        return components;
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

        GUI::SetFont(font);
        GUI::DrawText(text, position, position + size, color, false, false);
    }
}
