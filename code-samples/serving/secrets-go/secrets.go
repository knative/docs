package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"cloud.google.com/go/storage"
)

func main() {
	log.Print("Secrets sample started.")

	// This sets up the standard GCS storage client, which will pull
	// credentials from GOOGLE_APPLICATION_DEFAULT if specified.
	ctx := context.Background()
	client, err := storage.NewClient(ctx)
	if err != nil {
		log.Fatalf("Unable to initialize storage client: %v", err)
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// This GCS bucket has been configured so that any authenticated
		// user can access it (Read Only), so any Service Account can
		// run this sample.
		bkt := client.Bucket("knative-secrets-sample")

		// Access the attributes of this GCS bucket, and write it back to the
		// user.  On failure, return a 500 and the error message.
		attrs, err := bkt.Attrs(ctx)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		fmt.Fprintln(w,
			fmt.Sprintf("bucket %s, created at %s, is located in %s with storage class %s\n",
				attrs.Name, attrs.Created, attrs.Location, attrs.StorageClass))

	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}
