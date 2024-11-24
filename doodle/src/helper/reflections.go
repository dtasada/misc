package helper

import (
	"fmt"
	"reflect"
)

func ExpectType[T any](r any) T {
	expectedType := reflect.TypeOf((*T)(nil)).Elem()
	receivedType := reflect.TypeOf(r)

	if expectedType == receivedType {
		return r.(T)
	} else {
		panic(fmt.Sprintf("Expected %s but received %d instead", expectedType, receivedType))
	}
}
