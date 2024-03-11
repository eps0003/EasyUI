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

class CachedMinBoundsHandler : EventHandler
{
    private Component@ component;

    CachedMinBoundsHandler(Component@ component)
    {
        @this.component = component;
    }

    void Handle()
    {
        component.CalculateMinBounds();
    }
}
