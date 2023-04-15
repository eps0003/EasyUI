interface Slider : Component
{
    void SetPercentage(float percentage);
    float getPercentage();

    void SetSize(float width, float height);
    Vec2f getSize();

    void SetHandleSize(float size);
    float getHandleSize();
}

interface VerticalSlider : Slider
{

}

interface HorizontalSlider : Slider
{

}

class StandardVerticalSlider : VerticalSlider
{
    private EasyUI@ ui;

    private float percentage = 0.0f;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private float handleSize = 0.0f;
    private bool pressed = false;
    private float clickOffsetY;
    private EventListener@ events = StandardEventListener();

    StandardVerticalSlider(EasyUI@ ui)
    {
        @this.ui = ui;
    }

    void SetPercentage(float percentage)
    {
        percentage = Maths::Clamp01(percentage);

        if (this.percentage == percentage) return;

        this.percentage = percentage;

        DispatchEvent("change");
    }

    float getPercentage()
    {
        return percentage;
    }

    void SetSize(float width, float height)
    {
        if (size.x == width && size.y == height) return;

        size.x = width;
        size.y = height;

        DispatchEvent("resize");

        if (handleSize == 0.0f)
        {
            SetHandleSize(size.y * 0.2f);
        }
    }

    Vec2f getSize()
    {
        return size;
    }

    void SetHandleSize(float size)
    {
        handleSize = size;
    }

    float getHandleSize()
    {
        return handleSize;
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
        return true;
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

    private bool isHandleHovered()
    {
        Vec2f min = getHandlePosition();
        Vec2f max = min + Vec2f(size.x, handleSize);
        return isMouseInBounds(min, max);
    }

    private Vec2f getHandlePosition()
    {
        float handleY = (size.y - handleSize) * percentage;
        return position + Vec2f(0.0f, handleY);
    }

    private void MoveHandleIfDragging()
    {
        if (!pressed) return;

        float mouseY = getControls().getInterpMouseScreenPos().y;
        float handleY = mouseY - handleSize * clickOffsetY;
        SetPercentage((handleY - position.y) / Maths::Max(size.y - handleSize, 1.0f));
    }

    void Update()
    {
        CControls@ controls = getControls();

        if (controls.isKeyJustPressed(KEY_LBUTTON))
        {
            if (isHandleHovered() && ui.canClick(this))
            {
                // Drag handle relative to cursor if clicking on handle
                pressed = true;
                clickOffsetY = (controls.getInterpMouseScreenPos().y - getHandlePosition().y) / Maths::Max(handleSize, 1.0f);
                DispatchEvent("dragstart");
            }
        }

        // Call this here to override any external code updating the percentage
        MoveHandleIfDragging();

        if (!controls.isKeyPressed(KEY_LBUTTON) && pressed)
        {
            pressed = false;
            DispatchEvent("dragend");
        }
    }

    void Render()
    {
        GUI::DrawSunkenPane(position, position + size);

        // Call this here to make dragging look smooth
        MoveHandleIfDragging();

        float handleY = (size.y - handleSize) * percentage;
        Vec2f min = position + Vec2f(0, handleY);
        Vec2f max = position + Vec2f(size.x, handleSize + handleY);

        if (pressed || (isHandleHovered() && ui.canClick(this)))
        {
            GUI::DrawButtonHover(min, max);
        }
        else
        {
            GUI::DrawButton(min, max);
        }
    }
}

class StandardHorizontalSlider : HorizontalSlider
{
    private EasyUI@ ui;

    private float percentage = 0.0f;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private float handleSize = 0.0f;
    private bool pressed = false;
    private float clickOffsetX;
    private EventListener@ events = StandardEventListener();

    StandardHorizontalSlider(EasyUI@ ui)
    {
        @this.ui = ui;
    }

    void SetPercentage(float percentage)
    {
        percentage = Maths::Clamp01(percentage);

        if (this.percentage == percentage) return;

        this.percentage = percentage;

        DispatchEvent("change");
    }

    float getPercentage()
    {
        return percentage;
    }

    void SetSize(float width, float height)
    {
        if (size.x == width && size.y == height) return;

        size.x = width;
        size.y = height;

        DispatchEvent("resize");

        if (handleSize == 0.0f)
        {
            SetHandleSize(size.x * 0.2f);
        }
    }

    Vec2f getSize()
    {
        return size;
    }

    void SetHandleSize(float size)
    {
        handleSize = Maths::Max(size, 20.0f);
    }

    float getHandleSize()
    {
        return handleSize;
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
        return true;
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

    private bool isHandleHovered()
    {
        Vec2f min = getHandlePosition();
        Vec2f max = min + Vec2f(handleSize, size.y);
        return isMouseInBounds(min, max);
    }

    private Vec2f getHandlePosition()
    {
        float handleX = (size.x - handleSize) * percentage;
        return position + Vec2f(handleX, 0.0f);
    }

    void Update()
    {
        CControls@ controls = getControls();

        if (controls.isKeyJustPressed(KEY_LBUTTON))
        {
            if (isHandleHovered() && ui.canClick(this))
            {
                // Drag handle relative to cursor if clicking on handle
                pressed = true;
                clickOffsetX = (controls.getInterpMouseScreenPos().x - getHandlePosition().x) / Maths::Max(handleSize, 1.0f);
                DispatchEvent("dragstart");
            }
        }

        if (!controls.isKeyPressed(KEY_LBUTTON) && pressed)
        {
            pressed = false;
            DispatchEvent("dragend");
        }
    }

    private void MoveHandleIfDragging()
    {
        if (!pressed) return;

        float mouseX = getControls().getInterpMouseScreenPos().x;
        float handleX = mouseX - handleSize * clickOffsetX;
        SetPercentage((handleX - position.x) / Maths::Max(size.x - handleSize, 1.0f));
    }

    void Render()
    {
        float handleX = (size.x - handleSize) * percentage;

        GUI::DrawSunkenPane(position, position + size);

        Vec2f min = position + Vec2f(handleX, 0);
        Vec2f max = position + Vec2f(handleSize + handleX, size.y);

        if (pressed || (isHandleHovered() && ui.canClick(this)))
        {
            GUI::DrawButtonHover(min, max);
        }
        else
        {
            GUI::DrawButton(min, max);
        }
    }
}
