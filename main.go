package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	fmt.Println("Hivemind's Go Greeter")
	fmt.Println("You are running the service with this tag: ", os.Getenv("HELLO_TAG"))
	http.HandleFunc("/", HelloServer)
	http.ListenAndServe(":8080", nil)
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	params := r.URL.Query()
	name := params.Get("name")
	fmtStr := ""
	if name == "" {
		fmtStr = fmt.Sprintf("Hello, %s! I'm %s. Seems like you missed an opportunity to show your name. Add it as a query string to the URL (i.e. http://some.end.point.com/?name=your-beautiful-name )", GetIPFromRequest(r), os.Getenv("HOSTNAME"))
	} else {
		fmtStr = fmt.Sprintf("Hello, %s! I'm %s, you seems to be %s", GetIPFromRequest(r), os.Getenv("HOSTNAME"), name)
	}
	fmt.Println(fmtStr)
	fmt.Fprintln(w, fmtStr)
}

func GetIPFromRequest(r *http.Request) string {
	if fwd := r.Header.Get("x-forwarded-for"); fwd != "" {
		return fwd
	}

	return r.RemoteAddr
}
