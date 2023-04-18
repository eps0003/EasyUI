class DragHandle : Draggable
{
    private EasyUI@ ui;
    private Component@ handle;
    private Component@ component;
    private ClickHandler@ clickHandler;

    private bool dragging = false;
    private bool wasDragging = false;
    private Vec2f dragOffset = Vec2f_zero;

    DragHandle(EasyUI@ ui, Component@ handle, Component@ component)
    {
        @this.handle = handle;
        @this.component = component;
        @clickHandler = ClickHandler(ui, handle);
    }

    bool isDragging()
    {
        return clickHandler.isPressed();
    }

    void Update()
    {
        wasDragging = isDragging();
        clickHandler.Update();

        if (!wasDragging && isDragging())
        {
            dragOffset = getControls().getInterpMouseScreenPos() - component.getPosition();
            dragOffset /= component.getBounds();
        }
    }

    void Render()
    {
        if (!isDragging()) return;

        Vec2f mousePos = getControls().getInterpMouseScreenPos();
        mousePos.x = Maths::Clamp(mousePos.x, 0, getScreenWidth());
        mousePos.y = Maths::Clamp(mousePos.y, 0, getScreenHeight());

        Vec2f offset = component.getBounds();
        offset *= dragOffset;

        Vec2f pos = mousePos - offset;

        component.SetPosition(pos.x, pos.y);
    }
}
