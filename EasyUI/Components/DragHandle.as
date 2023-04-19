class DragHandle : Draggable
{
    private EasyUI@ ui;
    private Component@ handle;
    private Component@ component;

    private bool dragging = false;
    private bool wasDragging = false;
    private Vec2f dragOffset = Vec2f_zero;

    DragHandle(EasyUI@ ui, Component@ handle, Component@ component)
    {
        @this.ui = ui;
        @this.handle = handle;
        @this.component = component;
    }

    bool isDragging()
    {
        return dragging;
    }

    void Update()
    {
        dragging = ui.isInteractingWith(handle);

        if (!wasDragging && isDragging())
        {
            Vec2f bounds = handle.getBounds();
            if (bounds.LengthSquared() > 0)
            {
                dragOffset = getControls().getInterpMouseScreenPos() - handle.getPosition();
                dragOffset /= bounds;
            }
            else
            {
                dragOffset.Set(0.5f, 0.5f);
            }

            print(dragOffset.toString());
        }

        wasDragging = dragging;
    }

    void Render()
    {
        if (!isDragging()) return;

        Vec2f mousePos = getControls().getInterpMouseScreenPos();
        mousePos.x = Maths::Clamp(mousePos.x, 0, getScreenWidth());
        mousePos.y = Maths::Clamp(mousePos.y, 0, getScreenHeight());

        Vec2f offset = handle.getBounds();
        offset *= dragOffset;

        Vec2f pos = mousePos - offset - handle.getPosition() + component.getPosition();

        component.SetPosition(pos.x, pos.y);
    }
}
