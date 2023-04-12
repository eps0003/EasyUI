interface EventListener
{
    void AddEventListener(string type, EventHandler@ handler);
    void RemoveEventListener(string type, EventHandler@ handler);
    void DispatchEvent(string type);
}

interface EventHandler
{
    void Handle();
}

class StandardEventListener : EventListener
{
    private string[] eventTypes;
    private EventHandler@[] eventHandlers;

    void AddEventListener(string type, EventHandler@ handler)
    {
        if (handler is null) return;

        eventTypes.push_back(type);
        eventHandlers.push_back(handler);
    }

    void RemoveEventListener(string type, EventHandler@ handler)
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

    void DispatchEvent(string type)
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
