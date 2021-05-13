/*
Copyright 2020 The Knative Authors
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    https://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

using System.Text.Json.Serialization;

namespace CloudEventsSample.Models
{
    public class SampleOutput
    {
        /// <summary>
        /// Cloud Events SDK for .NET unfortunately still uses Newtonsoft.Json and is not up to date with .Net Core 3.
        /// We need to provide Newtonsoft.Json.JsonProperty attribute to ensure that CloudEvent.Data is serialized
        /// the way we want it to.
        /// JsonPropertyName is to ensure that deserialization through System.Text.Json.Serialization is done correctly.
        /// </summary>
        [JsonPropertyName("message")]
        [Newtonsoft.Json.JsonProperty("message")]
        public string Message { get; set; }
    }
}
