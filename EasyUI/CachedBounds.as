class CachedBoundsHandler : EventHandler
{
    private Component@ component;

    CachedBoundsHandler(Component@ component)
    {
        @this.component = component;
    }

    void Handle()
    {
        component.CalculateBounds();
    }
}

interface CachedBounds
{
    Vec2f getBounds();
}
