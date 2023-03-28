interface CachedBounds
{
    void CalculateBounds();
}

class CachedBoundsHandler : EventHandler
{
    private CachedBounds@ component;

    CachedBoundsHandler(CachedBounds@ component)
    {
        @this.component = component;
    }

    void Handle()
    {
        component.CalculateBounds();
    }
}
