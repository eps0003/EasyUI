interface Slider : Component
{
    void SetMinSize(float width, float height);
    Vec2f getMinSize();

    void SetMaxSize(float width, float height);
    Vec2f getMaxSize();

    void SetStretchRatio(float x, float y);
    Vec2f getStretchRatio();

    void SetPercentage(float percentage);
    float getPercentage();

    void SetHandleRatio(float ratio);
    float getHandleRatio();
}

class StandardVerticalSlider : Slider
{
    private EasyUI@ ui;

    private Component@ parent;

    private float percentage = 0.0f;
    private Vec2f margin = Vec2f_zero;
    private Vec2f minSize = Vec2f_zero;
    private Vec2f maxSize = Vec2f_zero;
    private Vec2f stretch = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private float handleRatio = 0.2f;
    private bool pressed = false;
    private float clickOffsetY;

    private EventDispatcher@ events = StandardEventDispatcher();

    StandardVerticalSlider()
    {
        error("Initialized StandardVerticalSlider using the default constructor. Use StandardVerticalSlider(EasyUI@ ui) instead.");
        printTrace();

        @ui = EasyUI();
    }

    StandardVerticalSlider(EasyUI@ ui)
    {
        @this.ui = ui;
    }

    void SetParent(Component@ parent)
    {
        if (this.parent is parent) return;

        @this.parent = parent;

        CalculateBounds();
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

    void SetHandleRatio(float ratio)
    {
        handleRatio = Maths::Clamp01(ratio);
    }

    float getHandleRatio()
    {
        return handleRatio;
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
        return minSize + margin * 2.0f;
    }

    Vec2f getBounds()
    {
        Vec2f outerBounds = getMinBounds();

        if (parent !is null)
        {
            Vec2f parentBounds = parent.getInnerBounds();
            parentBounds *= getStretchRatio();

            Vec2f maxBounds;
            maxBounds.x = maxSize.x != 0.0f ? Maths::Min(parentBounds.x, maxSize.x) : parentBounds.x;
            maxBounds.y = maxSize.y != 0.0f ? Maths::Min(parentBounds.y, maxSize.y) : parentBounds.y;

            outerBounds.x = Maths::Max(outerBounds.x, maxBounds.x);
            outerBounds.y = Maths::Max(outerBounds.y, maxBounds.y);
        }

        return outerBounds;
    }

    Vec2f getTrueBounds()
    {
        return getBounds() - margin * 2.0f;
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
        Vec2f max = min + getHandleSize();
        return isMouseInBounds(min, max);
    }

    private Vec2f getHandlePosition()
    {
        float handleY = (getTrueBounds().y - getHandleSize().y) * percentage;
        return getTruePosition() + Vec2f(0.0f, handleY);
    }

    private Vec2f getHandleSize()
    {
        Vec2f trueBounds = getTrueBounds();
        return Vec2f(trueBounds.x, trueBounds.y * handleRatio);
    }

    private void MoveHandleIfDragging()
    {
        if (!pressed) return;

        Vec2f sliderPos = getTruePosition();
        Vec2f sliderSize = getTrueBounds();
        Vec2f handleSize = getHandleSize();
        Vec2f mousePos = getControls().getInterpMouseScreenPos();

        float handleY = mousePos.y - handleSize.y * clickOffsetY;
        float percentage = (handleY - sliderPos.y) / Maths::Max(sliderSize.y - handleSize.y, 1.0f);

        SetPercentage(percentage);
    }

    void Update()
    {
        CControls@ controls = getControls();

        if (!pressed && ui.startedInteractingWith(this) && isHandleHovered())
        {
            // Drag handle relative to cursor if clicking on handle
            pressed = true;
            clickOffsetY = (controls.getInterpMouseScreenPos().y - getHandlePosition().y) / Maths::Max(getHandleSize().y, 1.0f);
            DispatchEvent("dragstart");
        }

        // Call this here to override any external code updating the percentage
        MoveHandleIfDragging();

        if (pressed && !ui.isInteractingWith(this))
        {
            pressed = false;
            DispatchEvent("dragend");
        }
    }

    void Render()
    {
        // Call this here to make dragging look smooth
        MoveHandleIfDragging();

        Vec2f sliderMin = getTruePosition();
        Vec2f sliderMax = sliderMin + getTrueBounds();
        Vec2f handleMin = getHandlePosition();
        Vec2f handleMax = handleMin + getHandleSize();

        GUI::DrawSunkenPane(sliderMin, sliderMax);

        if (pressed || (isHandleHovered() && ui.canClick(this)))
        {
            GUI::DrawButtonHover(handleMin, handleMax);
        }
        else
        {
            GUI::DrawButton(handleMin, handleMax);
        }
    }
}

// class StandardHorizontalSlider : Slider
// {
//     private EasyUI@ ui;

//     private float percentage = 0.0f;
//     private Vec2f size = Vec2f_zero;
//     private Vec2f position = Vec2f_zero;
//     private float handleSize = 0.0f;
//     private bool pressed = false;
//     private float clickOffsetX;
//     private EventDispatcher@ events = StandardEventDispatcher();

//     StandardHorizontalSlider(EasyUI@ ui)
//     {
//         @this.ui = ui;
//     }

//     void SetPercentage(float percentage)
//     {
//         percentage = Maths::Clamp01(percentage);

//         if (this.percentage == percentage) return;

//         this.percentage = percentage;

//         DispatchEvent("change");
//     }

//     float getPercentage()
//     {
//         return percentage;
//     }

//     void SetSize(float width, float height)
//     {
//         if (size.x == width && size.y == height) return;

//         size.x = width;
//         size.y = height;

//         DispatchEvent("resize");

//         if (handleSize == 0.0f)
//         {
//             SetHandleSize(size.x * 0.2f);
//         }
//     }

//     Vec2f getSize()
//     {
//         return size;
//     }

//     void SetHandleSize(float size)
//     {
//         handleSize = Maths::Max(size, 12.0f);
//     }

//     float getHandleSize()
//     {
//         return handleSize;
//     }

//     void SetPosition(float x, float y)
//     {
//         position.x = x;
//         position.y = y;
//     }

//     Vec2f getPosition()
//     {
//         return position;
//     }

//     Vec2f getBounds()
//     {
//         return size;
//     }

//     void CalculateBounds()
//     {

//     }

//     bool isHovering()
//     {
//         return isMouseInBounds(position, position + size);
//     }

//     bool canClick()
//     {
//         return true;
//     }

//     bool canScroll()
//     {
//         return false;
//     }

//     Component@[] getComponents()
//     {
//         Component@[] components;
//         return components;
//     }

//     void AddEventListener(string type, EventHandler@ handler)
//     {
//         events.AddEventListener(type, handler);
//     }

//     void RemoveEventListener(string type, EventHandler@ handler)
//     {
//         events.RemoveEventListener(type, handler);
//     }

//     void DispatchEvent(string type)
//     {
//         events.DispatchEvent(type);
//     }

//     private bool isHandleHovered()
//     {
//         Vec2f min = getHandlePosition();
//         Vec2f max = min + Vec2f(handleSize, size.y);
//         return isMouseInBounds(min, max);
//     }

//     private Vec2f getHandlePosition()
//     {
//         float handleX = (size.x - handleSize) * percentage;
//         return position + Vec2f(handleX, 0.0f);
//     }

//     void Update()
//     {
//         CControls@ controls = getControls();

//         if (controls.isKeyJustPressed(KEY_LBUTTON) && isHandleHovered() && ui.canClick(this))
//         {
//             // Drag handle relative to cursor if clicking on handle
//             pressed = true;
//             clickOffsetX = (controls.getInterpMouseScreenPos().x - getHandlePosition().x) / Maths::Max(handleSize, 1.0f);
//             DispatchEvent("dragstart");
//         }

//         if (!controls.isKeyPressed(KEY_LBUTTON) && pressed)
//         {
//             pressed = false;
//             DispatchEvent("dragend");
//         }
//     }

//     private void MoveHandleIfDragging()
//     {
//         if (!pressed) return;

//         float mouseX = getControls().getInterpMouseScreenPos().x;
//         float handleX = mouseX - handleSize * clickOffsetX;
//         SetPercentage((handleX - position.x) / Maths::Max(size.x - handleSize, 1.0f));
//     }

//     void Render()
//     {
//         float handleX = (size.x - handleSize) * percentage;

//         GUI::DrawSunkenPane(position, position + size);

//         Vec2f min = position + Vec2f(handleX, 0);
//         Vec2f max = position + Vec2f(handleSize + handleX, size.y);

//         if (pressed || (isHandleHovered() && ui.canClick(this)))
//         {
//             GUI::DrawButtonHover(min, max);
//         }
//         else
//         {
//             GUI::DrawButton(min, max);
//         }
//     }
// }
