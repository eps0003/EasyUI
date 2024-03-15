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

class PlaySoundHandler : EventHandler
{
    private string sound = "";

    PlaySoundHandler(string sound)
    {
        this.sound = sound;
    }

    void Handle()
    {
        Sound::Play(sound);
    }
}

class ToggleClickHandler : EventHandler
{
    private Toggle@ toggle;

    ToggleClickHandler(Toggle@ toggle)
    {
        @this.toggle = toggle;
    }

    void Handle()
    {
        toggle.SetChecked(!toggle.isChecked());
    }
}
