// Machine generated IDispatch wrapper class(es) created with Add Class from Typelib Wizard

// IMCSMea21StimulatorProperty wrapper class

class IMCSMea21StimulatorProperty : public COleDispatchDriver
{
public:
	IMCSMea21StimulatorProperty(){} // Calls COleDispatchDriver default constructor
	IMCSMea21StimulatorProperty(LPDISPATCH pDispatch) : COleDispatchDriver(pDispatch) {}
	IMCSMea21StimulatorProperty(const IMCSMea21StimulatorProperty& dispatchSrc) : COleDispatchDriver(dispatchSrc) {}

	// Attributes
public:

	// Operations
public:


	// IMCSMea21StimulatorProperty methods
public:
	long GetNumberOfStreams()
	{
		long result;
		InvokeHelper(0x1, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}

	// IMCSMea21StimulatorProperty properties
public:

};
