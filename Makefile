CFLAGS = 

LDFLAGS = 

build:
	swift build $(CFLAGS) $(LDFLAGS)

xcode:
	swift package $(CFLAGS) $(LDFLAGS) generate-xcodeproj
	
test:
	swift build $(CFLAGS) $(LDFLAGS)
	swift test $(CFLAGS) $(LDFLAGS) 

clean:
	rm -rf Packages
	rm -rf .build
	rm -rf *.xcodeproj
	rm -rf Package.pins