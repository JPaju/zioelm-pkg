module Api exposing (RemoteData(..), fetchPackageDetails, fetchPackageListing)

import Http
import Package exposing (PackageId, PackageListing, listingDecoder, packageDetailsDecoder)


type RemoteData e a
    = Loading
    | Finished a
    | Errored e


baseUrl =
    "http://localhost:8080/packages/"


fetchPackageListing : (Result Http.Error PackageListing -> msg) -> Cmd msg
fetchPackageListing toMsg =
    Http.get
        { url = baseUrl
        , expect = Http.expectJson toMsg listingDecoder
        }


fetchPackageDetails : PackageId -> (Result Http.Error Package.PackageDetails -> msg) -> Cmd msg
fetchPackageDetails packageId toMsg =
    Http.get
        { url = baseUrl ++ Package.getIdStr packageId
        , expect = Http.expectJson toMsg packageDetailsDecoder
        }
