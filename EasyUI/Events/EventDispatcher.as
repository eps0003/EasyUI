interface EventDispatcher
{
    void AddEventListener(Event type, EventHandler@ handler);
    void RemoveEventListener(Event type, EventHandler@ handler);
    void DispatchEvent(Event type);
}

interface EventHandler
{
    void Handle();
}

class StandardEventDispatcher : EventDispatcher
{
    private Event[] eventTypes;
    private EventHandler@[] eventHandlers;

    void AddEventListener(Event type, EventHandler@ handler)
    {
        if (handler is null) return;

        eventTypes.push_back(type);
        eventHandlers.push_back(handler);
    }

    void RemoveEventListener(Event type, EventHandler@ handler)
    {
        if (handler is null) return;

        for (int i = eventHandlers.size() - 1; i >= 0; i--)
        {
            EventHandler@ other = eventHandlers[i];
            if (other !is handler) continue;

            eventTypes.removeAt(i);
            eventHandlers.removeAt(i);

            break;
        }
    }

    void DispatchEvent(Event type)
    {
        for (uint i = 0; i < eventHandlers.size(); i++)
        {
            if (eventTypes[i] == type)
            {
                eventHandlers[i].Handle();
            }
        }
    }
}
