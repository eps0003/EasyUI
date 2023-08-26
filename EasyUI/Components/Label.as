interface Label : Component
{
    void SetText(string text);
    string getText();

    void SetFont(string font);
    string getFont();

    void SetColor(SColor color);
    SColor getColor();

    void SetClickable(bool clickable);
}

interface AreaLabel : Label
{
    void SetMinSize(float width, float height);
    Vec2f getMinSize();

    void SetMaxSize(float width, float height);
    Vec2f getMaxSize();

    void SetStretchRatio(float x, float y);
    Vec2f getStretchRatio();
}

class StandardLabel : Label
{
    private Component@ parent;

    private string text = "";
    private string font = "menu";
    private SColor color = color_black;
    private Vec2f margin = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private bool clickable = false;

    private Vec2f trueBounds = Vec2f_zero;
    private bool calculateBounds = true;

    private EventDispatcher@ events = StandardEventDispatcher();

    void SetParent(Component@ parent)
    {
        if (this.parent is parent) return;

        @this.parent = parent;

        CalculateBounds();
    }

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

    void SetMargin(float x, float y)
    {
        x = Maths::Max(0, x);
        y = Maths::Max(0, y);

        if (margin.x == x && margin.y == y) return;

        margin.x = x;
        margin.y = y;

        CalculateBounds();
    }

    Vec2f getMargin()
    {
        return margin;
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

    Vec2f getTruePosition()
    {
        return getPosition() + margin;
    }

    Vec2f getInnerPosition()
    {
        return getTruePosition();
    }

    Vec2f getMinBounds()
    {
        return getBounds();
    }

    Vec2f getBounds()
    {
        return getTrueBounds() + margin * 2.0f;
    }

    Vec2f getTrueBounds()
    {
        if (calculateBounds)
        {
            calculateBounds = false;

            GUI::SetFont(font);
            GUI::GetTextDimensions(text, trueBounds);
        }

        return trueBounds;
    }

    Vec2f getInnerBounds()
    {
        return getTrueBounds();
    }

    void CalculateBounds()
    {
        if (calculateBounds) return;

        calculateBounds = true;

        DispatchEvent("resize");
    }

    bool isHovering()
    {
        return ::isHovering(this);
    }

    void SetClickable(bool clickable)
    {
        this.clickable = clickable;
    }

    bool canClick()
    {
        return clickable;
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
        // May only be applicable with the default KAG font?
        Vec2f pos = getTruePosition() - Vec2f(3, 1);

        GUI::SetFont(font);
        GUI::DrawText(text, pos, color);
    }
}

class StandardAreaLabel : AreaLabel
{
    private Component@ parent;

    private string text = "";
    private string font = "menu";
    private SColor color = color_black;
    private Vec2f minSize = Vec2f_zero;
    private Vec2f maxSize = Vec2f_zero;
    private Vec2f stretch = Vec2f_zero;
    private Vec2f margin = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private bool clickable = false;

    private EventDispatcher@ events = StandardEventDispatcher();

    void SetParent(Component@ parent)
    {
        if (this.parent is parent) return;

        @this.parent = parent;

        CalculateBounds();
    }

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

    void SetMargin(float x, float y)
    {
        x = Maths::Max(0, x);
        y = Maths::Max(0, y);

        if (margin.x == x && margin.y == y) return;

        margin.x = x;
        margin.y = y;
    }

    Vec2f getMargin()
    {
        return margin;
    }

    void SetMinSize(float width, float height)
    {
        if (minSize.x == width && minSize.y == height) return;

        minSize.x = width;
        minSize.y = height;

        CalculateBounds();
    }

    Vec2f getMinSize()
    {
        return minSize;
    }

    void SetMaxSize(float width, float height)
    {
        if (maxSize.x == width && maxSize.y == height) return;

        maxSize.x = width;
        maxSize.y = height;

        CalculateBounds();
    }

    Vec2f getMaxSize()
    {
        return maxSize;
    }

    void SetStretchRatio(float x, float y)
    {
        stretch.x = Maths::Clamp01(x);
        stretch.y = Maths::Clamp01(y);
    }

    Vec2f getStretchRatio()
    {
        return stretch;
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

    Vec2f getTruePosition()
    {
        return getPosition() + margin;
    }

    Vec2f getInnerPosition()
    {
        return getTruePosition();
    }

    Vec2f getMinBounds()
    {
        return getBounds();
    }

    Vec2f getBounds()
    {
        return getTrueBounds() + margin * 2.0f;
    }

    Vec2f getTrueBounds()
    {
        return minSize;
    }

    Vec2f getInnerBounds()
    {
        return getTrueBounds();
    }

    void CalculateBounds()
    {
        DispatchEvent("resize");
    }

    bool isHovering()
    {
        return ::isHovering(this);
    }

    void SetClickable(bool clickable)
    {
        this.clickable = clickable;
    }

    bool canClick()
    {
        return clickable;
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
        GUI::DrawText(text, position, position + minSize, color, false, false);
    }
}
