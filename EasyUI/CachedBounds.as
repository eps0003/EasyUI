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
