#ifndef ROSIDL_RUNTIME_CPP__TRAITS_HPP_
#define ROSIDL_RUNTIME_CPP__TRAITS_HPP_

#include <type_traits>

template <typename T>
struct ParentTypeTraits;

namespace rosidl_generator_traits
{

template<typename...>
using void_t = void;

template<typename T, typename = void>
struct is_message : std::false_type
{
};

template<typename T>
struct is_message<T, void_t<typename ParentTypeTraits<T>::Type>> : std::true_type
{
};

}  // namespace rosidl_generator_traits

#endif  // ROSIDL_RUNTIME_CPP__TRAITS_HPP_
