interface Slider : Component
{
    void SetPercentage(float percentage);
    void SetSize(float width, float height);
    void SetHandleSize(float size);
}

class VerticalSlider : Slider
{
    private float percentage = 0.0f;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private float handleSize = 0.0f;
    private bool pressed = false;
    private float clickOffsetY;

    void SetPercentage(float percentage)
    {
        this.percentage = Maths::Clamp01(percentage);
    }

    void SetSize(float width, float height)
    {
        size.x = width;
        size.y = height;

        if (handleSize == 0.0f)
        {
            handleSize = size.y * 0.2f;
        }
    }

    void SetHandleSize(float size)
    {
        handleSize = size;
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

    private bool isHovered()
    {
        Vec2f mousePos = getControls().getInterpMouseScreenPos();
        return (
            mousePos.x >= position.x &&
            mousePos.y >= position.y &&
            mousePos.x <= position.x + size.x &&
            mousePos.y <= position.y + size.y
        );
    }

    private bool isHandleHovered()
    {
        Vec2f mousePos = getControls().getInterpMouseScreenPos();
        Vec2f handlePos = getHandlePosition();
        return (
            mousePos.x >= handlePos.x &&
            mousePos.y >= handlePos.y &&
            mousePos.x <= handlePos.x + size.x &&
            mousePos.y <= handlePos.y + handleSize
        );
    }

    private Vec2f getHandlePosition()
    {
        float handleY = (size.y - handleSize) * percentage;
        return position + Vec2f(0.0f, handleY);
    }

    void Update()
    {
        CControls@ controls = getControls();

        if (controls.isKeyJustPressed(KEY_LBUTTON))
        {
            if (isHandleHovered())
            {
                // Drag handle relative to cursor if clicking on handle
                pressed = true;
                clickOffsetY = getControls().getInterpMouseScreenPos().y - getHandlePosition().y;
            }
            // else if (isHovered())
            // {
            //     // Jump handle to cursor if clicking on track
            //     pressed = true;
            //     clickOffsetY = handleSize * 0.5f;
            // }
        }

        // Call this here to override any external code updating the percentage
        MoveHandleIfDragging();

        if (!controls.isKeyPressed(KEY_LBUTTON) && pressed)
        {
            pressed = false;
        }
    }

    void MoveHandleIfDragging()
    {
        if (!pressed) return;

        float mouseY = getControls().getInterpMouseScreenPos().y;
        float handleY = mouseY - clickOffsetY;
        SetPercentage((handleY - position.y) / (size.y - handleSize));
    }

    void Render()
    {
        float handleY = (size.y - handleSize) * percentage;

        GUI::DrawSunkenPane(position, position + size);

        // Call this here to make dragging look smooth
        MoveHandleIfDragging();

        if (pressed || isHandleHovered())
        {
            GUI::DrawButtonHover(position + Vec2f(0, handleY), position + Vec2f(size.x, handleSize + handleY));
        }
        else
        {
            GUI::DrawButton(position + Vec2f(0, handleY), position + Vec2f(size.x, handleSize + handleY));
        }
    }
}
