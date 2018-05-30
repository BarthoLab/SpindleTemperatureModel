classdef (ConstructOnLoad) ListHandlerEDC < event.EventData
   properties
      ID;
      Element;
   end
   methods
      function eventData = ListHandlerEDC(id, element)
         eventData.ID = id;
         eventData.Element = element;
      end
   end
end
