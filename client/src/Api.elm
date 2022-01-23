module Api exposing (..)

import Http
import Package exposing (PackageListing, listingDecoder, packageDetailsDecoder)



-- import Url exposing (Protocol(..))


type RemoteData e a
    = Loading
    | Finished a
    | Errored e


fetchPackageListing : (Result Http.Error PackageListing -> msg) -> Cmd msg
fetchPackageListing toMsg =
    Http.get
        { url = "http://localhost:8080/packages"
        , expect = Http.expectJson toMsg listingDecoder
        }


fetchPackageDetails : String -> (Result Http.Error Package.PackageDetails -> msg) -> Cmd msg
fetchPackageDetails packageName toMsg =
    Http.get
        { url = "http://localhost:8080/packages/" ++ packageName
        , expect = Http.expectJson toMsg packageDetailsDecoder
        }
