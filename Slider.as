interface Slider : Component
{
    void SetPercentage(float percentage);
    float getPercentage();

    void SetSize(float width, float height);
    Vec2f getSize();

    void SetHandleSize(float size);
    float getHandleSize();

    void OnStartDrag(EventHandler@ handler);
    void OnEndDrag(EventHandler@ handler);
    void OnChange(EventHandler@ handler);
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

    private EventHandler@[] startDragHandlers;
    private EventHandler@[] endDragHandlers;
    private EventHandler@[] changeHandlers;

    StandardVerticalSlider(EasyUI@ ui)
    {
        @this.ui = ui;
    }

    void SetPercentage(float percentage)
    {
        float prevPercentage = this.percentage;
        this.percentage = Maths::Clamp01(percentage);

        if (this.percentage != prevPercentage)
        {
            for (uint i = 0; i < changeHandlers.size(); i++)
            {
                changeHandlers[i].Handle();
            }
        }
    }

    float getPercentage()
    {
        return percentage;
    }

    void SetSize(float width, float height)
    {
        size.x = width;
        size.y = height;

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

    Component@ getHoveredComponent()
    {
        return isHovered() ? cast<Component>(this) : null;
    }

    void OnStartDrag(EventHandler@ handler)
    {
        if (handler !is null)
        {
            startDragHandlers.push_back(handler);
        }
    }

    void OnEndDrag(EventHandler@ handler)
    {
        if (handler !is null)
        {
            endDragHandlers.push_back(handler);
        }
    }

    void OnChange(EventHandler@ handler)
    {
        if (handler !is null)
        {
            changeHandlers.push_back(handler);
        }
    }

    private bool isHovered()
    {
        return isMouseInBounds(position, position + size);
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
            if (isHandleHovered() && ui.isComponentHovered(this))
            {
                // Drag handle relative to cursor if clicking on handle
                pressed = true;
                clickOffsetY = (controls.getInterpMouseScreenPos().y - getHandlePosition().y) / Maths::Max(handleSize, 1.0f);

                for (uint i = 0; i < startDragHandlers.size(); i++)
                {
                    startDragHandlers[i].Handle();
                }
            }
        }

        // Call this here to override any external code updating the percentage
        MoveHandleIfDragging();

        if (!controls.isKeyPressed(KEY_LBUTTON) && pressed)
        {
            pressed = false;

            for (uint i = 0; i < endDragHandlers.size(); i++)
            {
                endDragHandlers[i].Handle();
            }
        }
    }

    void Render()
    {
        float handleY = (size.y - handleSize) * percentage;

        GUI::DrawSunkenPane(position, position + size);

        // Call this here to make dragging look smooth
        MoveHandleIfDragging();

        Vec2f min = position + Vec2f(0, handleY);
        Vec2f max = position + Vec2f(size.x, handleSize + handleY);

        if (pressed || (isHandleHovered() && ui.isComponentHovered(this)))
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

    private EventHandler@[] startDragHandlers;
    private EventHandler@[] endDragHandlers;
    private EventHandler@[] changeHandlers;

    StandardHorizontalSlider(EasyUI@ ui)
    {
        @this.ui = ui;
    }

    void SetPercentage(float percentage)
    {
        float prevPercentage = this.percentage;
        this.percentage = Maths::Clamp01(percentage);

        if (this.percentage != prevPercentage)
        {
            for (uint i = 0; i < changeHandlers.size(); i++)
            {
                changeHandlers[i].Handle();
            }
        }
    }

    float getPercentage()
    {
        return percentage;
    }

    void SetSize(float width, float height)
    {
        size.x = width;
        size.y = height;

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

    Component@ getHoveredComponent()
    {
        return isHovered() ? cast<Component>(this) : null;
    }

    void OnStartDrag(EventHandler@ handler)
    {
        if (handler !is null)
        {
            startDragHandlers.push_back(handler);
        }
    }

    void OnEndDrag(EventHandler@ handler)
    {
        if (handler !is null)
        {
            endDragHandlers.push_back(handler);
        }
    }

    void OnChange(EventHandler@ handler)
    {
        if (handler !is null)
        {
            changeHandlers.push_back(handler);
        }
    }

    private bool isHovered()
    {
        return isMouseInBounds(position, position + size);
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

    private void MoveHandleIfDragging()
    {
        if (!pressed) return;

        float mouseX = getControls().getInterpMouseScreenPos().x;
        float handleX = mouseX - handleSize * clickOffsetX;
        SetPercentage((handleX - position.x) / Maths::Max(size.x - handleSize, 1.0f));
    }

    void Update()
    {
        CControls@ controls = getControls();

        if (controls.isKeyJustPressed(KEY_LBUTTON))
        {
            if (isHandleHovered() && ui.isComponentHovered(this))
            {
                // Drag handle relative to cursor if clicking on handle
                pressed = true;
                clickOffsetX = (controls.getInterpMouseScreenPos().x - getHandlePosition().x) / Maths::Max(handleSize, 1.0f);

                for (uint i = 0; i < startDragHandlers.size(); i++)
                {
                    startDragHandlers[i].Handle();
                }
            }
        }

        // Call this here to override any external code updating the percentage
        MoveHandleIfDragging();

        if (!controls.isKeyPressed(KEY_LBUTTON) && pressed)
        {
            pressed = false;

            for (uint i = 0; i < endDragHandlers.size(); i++)
            {
                endDragHandlers[i].Handle();
            }
        }
    }

    void Render()
    {
        float handleX = (size.x - handleSize) * percentage;

        GUI::DrawSunkenPane(position, position + size);

        // Call this here to make dragging look smooth
        MoveHandleIfDragging();

        Vec2f min = position + Vec2f(handleX, 0);
        Vec2f max = position + Vec2f(handleSize + handleX, size.y);

        if (pressed || (isHandleHovered() && ui.isComponentHovered(this)))
        {
            GUI::DrawButtonHover(min, max);
        }
        else
        {
            GUI::DrawButton(min, max);
        }
    }
}
