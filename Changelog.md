# Amplitude API Changelog

We would like to think our many [contributors](https://github.com/toothrot/amplitude-api/graphs/contributors) for
suggestions, ideas and improvements to Amplitude API.

## 0.4.0 (2022-04-28)
* Increases required Ruby version to supported ones. Minimum Ruby version is now 2.7
* Allows using version 2 of Faraday
* Upgrades development dependencies
* Adds more Rubocop rules

## 0.3.3 (2021-02-24)
* Relaxes Faraday dependency

## 0.3.2 (2021-02-23)
* Creates new properties on initialization

## 0.3.1 (2021-02-23)
* Allows sending options to Amplitude
* Solves an error when accessing event properties not been created yet

## 0.3.0 (2021-02-22)

* Changes Typhoeus to Faraday to launch requests (**breaking change**)
* Adds new API fields to Event
* Event can now include arbitrary properties, so it could be used if the API adds new ones.

## 0.2.0 (2021-02-14)

* Updates gem to use HTTP API V2.

## 0.1.1 (2019-01-01)

* Fix #41 - Delete API now correctly handles Arrays of IDs.

## 0.1.0 (2019-01-01)

* Update Gem dependencies (thanks @kolorahl, @itamar, @krettan)
* Minimum ruby version is now 2.2
* Support Delete API (thanks @samjohn)
* Fix bundle Inline (thanks @jonduarte)
* Many fixes from @kolorahl

## 0.0.10 (2017-09-13)

* Allow to use "Event Segmentation" via API ([#23](https://github.com/toothrot/amplitude-api/pull/23)).

## Older releases

Please see the v0.0.9 tag.
