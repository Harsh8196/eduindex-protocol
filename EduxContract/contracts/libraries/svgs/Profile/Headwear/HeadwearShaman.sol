// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Headwear} from '../Headwear.sol';
import {EduxColors} from '../EduxColors.sol';

library HeadwearShaman {
    enum ShamanColors {
        GREEN,
        PINK,
        PURPLE,
        BLUE,
        GOLD
    }

    function getShaman(
        ShamanColors shamanColor
    ) external pure returns (string memory, Headwear.HeadwearVariants, Headwear.HeadwearColors) {
        return (
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" width="222" height="335" x="-6" fill="none">',
                _getShamanStyle(shamanColor),
                '<path class="shamanColor2" d="m33.2 81.7 3.6 9.8 2.4-.5 2.4-.4-2.8-9-5.6.1ZM56.5 84l-1.8 7.4a37.2 37.2 0 0 0 4.2 1.4h.4l4.3-1.6.8-4.2-3.3-5.7-4.6 2.7Z"/><path class="shamanColor2" d="m124.6 66.2 17-11-4-3.3-23.5-9.5-16.8-6.7-9.7-2.8-12.8 2.8-9.4 9.1-5.8 14.5v17.8l7.6 16.1 6.3 4.7s1.4-18 16.2-27.5c15.4-9.9 34-3.9 34-3.9l1-.3Zm10.5 6.4 2.1 1.7 1 .5 2.7-7.3 2.9-9.1-.7-2.2-4.9 1.6-1.7 6.6-1.4 8.2Zm5.1 4s2.5 2.8 3.4 4.8c.6 1.5 1 3.6 1 3.6l-.6 15.7-2.7 12.8 2.1.7h6.8l-3.5 8.5.5 4.1 5.3 7.9 7 3.9 6.1-1 10-7.6v-12.4l7.7 1.4 4.8-10.6.5-12.1h7.1l-2.9-9.4-6.4-6.4-6.6-5-5.1-1.9-5.4 1.4-4.6 3.5-4.2-3.5-5.1-4h-6.2l-6.8 2.6-2.2 3Zm36.6-63.8a3.7 3.7 0 1 1 0-7.4 3.7 3.7 0 0 1 0 7.4Z"/><path class="shamanColor1" d="M211.4 59.3a5.1 5.1 0 1 1 0-10.3 5.1 5.1 0 0 1 0 10.3ZM165.8 82c-.8-2.7.3-6 2.6-7.7a9 9 0 0 1 8.2-.7 37.1 37.1 0 0 1 43 19.7 34 34 0 0 0-19-24.4A44 44 0 0 0 173 66l.2.5a52 52 0 0 0-14.8 5.7l-.1.7a17 17 0 0 1 7.5 9.1Z"/><path class="shamanColor2" d="m169 66.8 5.2-1.1a43.4 43.4 0 0 0 17.7-10 73.6 73.6 0 0 1-23.8 4.7l-1.5-3.2a54 54 0 0 0 10.6-4v-.1a41 41 0 0 1-12.3 3v1c2.2 2.9 3.2 6.6 3 10.2l.2.6a52 52 0 0 1 5-1.4V66c-1.4.4-2.7.6-4 .8Z"/><path class="shamanColor2" d="M164.9 56.1a60 60 0 0 1-20.3-2l-.2.4v1.3c-.6 7-2.7 14-6 20.3V76a16.3 16.3 0 0 1 15.9-4.8c1.4.4 2.7 1 4 1.7l.1-.7a59 59 0 0 1 9.7-4.3l-.2-.6a16 16 0 0 0-3-10.3v-.9ZM137.4 6.9h-.1a63 63 0 0 1 .9 18.1l.2.7 5.7-2-.4-1a31.3 31.3 0 0 0-6.3-15.8Zm-20.7 8.2a3.6 3.6 0 1 0 0 7.2 3.6 3.6 0 0 0 0-7.2Z"/><path class="shamanColor1" d="M23.2 97.6c-6.8 1.1-13 2-14 8.9a17 17 0 0 0 9 17.5c-3.2-10.3-1.2-17.6 5-26.4Z"/><path class="shamanColor2" d="M6.2 82.5a3.8 3.8 0 1 0 0 7.6 3.8 3.8 0 0 0 0-7.6Zm20.4-8.2A18 18 0 0 1 39 62.2l-.2-.7c-1.6.4-3.2 1-5 1.6A66.7 66.7 0 0 0 8.3 34.8 145 145 0 0 1 28 69c-.8 1.5-1.5 3.3-1.8 5.1h.3Z"/><path class="shamanColor2" d="M39 62.2a18 18 0 0 0-12.4 12h-.3a25 25 0 0 0-.4 7.8c-4.5-4-9.5-7.6-15.3-10.3 3.1 5.2 13 18.7 16.2 24.1l2.3-1.3 2.4-1s-6.1-9.2-4-11a44 44 0 0 0 12.3-18.6l2-5.6-.3-.2-1.6 3.1c-.4 0-.7.2-1 .3l.1.7Z"/><path class="shamanColor1" d="M39.8 64a44 44 0 0 1-12.2 18.4c5.1-2 10.9-1.9 16.5-2.3 2-.2 4.2-.4 6.3-1 3.4-.8 6.6-2.2 9-4.7h.4a41.7 41.7 0 0 1 .8-18h-.3a9.8 9.8 0 0 0-6.8-5.2c-3-.6-6.1.3-8.4 2.3-1.4 1.3-2.4 3-3.2 4.8-.8 1.8-1.4 3.8-2 5.6Z"/><path class="shamanColor2" d="M70 39.5a15 15 0 0 1 6.9-5l-.3-.7-1.2.5a28 28 0 0 0-3.6-11l-10 .1c1-2.8 1.7-5.6 2.5-8.7a29 29 0 0 0-14-7.4c-5.3-.9-11.1.7-14.5 4.9A19.2 19.2 0 0 0 32.5 24a46.6 46.6 0 0 0 10.9 30c-.6 1.3-1.2 2.7-2 4.1l.5.2c.8-1.8 1.8-3.5 3.2-4.8a9.7 9.7 0 0 1 15.2 2.9h.3a44.6 44.6 0 0 1 9-17.2l.3.3Z"/><path class="shamanColor2" d="M96.3 30.8c-6.6-.5-13.4.5-19.7 3l.3.7c2.3-1 5-1.5 7.5-1.6a44 44 0 0 1 17 3.4c12.5 4.7 24.1 11.4 36.7 15.8a60 60 0 0 0 26.8 4c4.2-.4 8.3-1.3 12.2-3l.1.2a55.6 55.6 0 0 0 17.3-13.1c.9-1 1.8-2.2 2.1-3.6.5-2.3-.8-4.7-2.5-6.5-3.6-4-8.7-6.6-14.2-6.7-5.8 2.7-11.8 5.1-17.6 7.5 0-3.3-.2-6.6 0-10-6.2-.6-12.3.7-18.2 2.7l-5.7 2-2.1 1c-8.4 3.3-16.8 7-25.8 7.6a46 46 0 0 0-14.2-3.4Z"/><path fill="#000" fill-opacity=".2" d="m33.2 81.7 3.6 9.8 2.4-.5 2.4-.4-2.8-9-5.6.1Z"/><path fill="#fff" fill-opacity=".5" d="m56.5 84-1.8 7.4a37.2 37.2 0 0 0 4.2 1.4h.4l4.3-1.6.8-4.2-3.3-5.7-4.6 2.7Z"/><path fill="#000" fill-opacity=".2" d="m124.6 66.2 17-11-4-3.3-23.5-9.5-16.8-6.7-9.7-2.8-12.8 2.8-9.4 9.1-5.8 14.5v17.8l7.6 16.1 6.3 4.7s1.4-18 16.2-27.5c15.4-9.9 34-3.9 34-3.9l1-.3Z"/><path fill="#fff" fill-opacity=".5" d="m135.1 72.6 2.1 1.7 1 .5 2.7-7.3 2.9-9.1-.7-2.2-4.9 1.6-1.7 6.6-1.4 8.2Zm5.1 4s2.5 2.8 3.4 4.8c.6 1.5 1 3.6 1 3.6l-.6 15.7-2.7 12.8 2.1.7h6.8l-3.5 8.5.5 4.1 5.3 7.9 7 3.9 6.1-1 10-7.6v-12.4l7.7 1.4 4.8-10.6.5-12.1h7.1l-2.9-9.4-6.4-6.4-6.6-5-5.1-1.9-5.4 1.4-4.6 3.5-4.2-3.5-5.1-4h-6.2l-6.8 2.6-2.2 3Zm36.6-63.8a3.7 3.7 0 1 1 0-7.4 3.7 3.7 0 0 1 0 7.4Zm-7.8 54 5.2-1.1a43.4 43.4 0 0 0 17.7-10 73.6 73.6 0 0 1-23.8 4.7l-1.5-3.2a54 54 0 0 0 10.6-4v-.1a41 41 0 0 1-12.3 3v1c2.2 2.9 3.2 6.6 3 10.2l.2.6a52 52 0 0 1 5-1.4V66c-1.4.4-2.7.6-4 .8Z"/><path fill="#000" fill-opacity=".2" d="M164.9 56.1a60 60 0 0 1-20.3-2l-.2.4v1.3c-.6 7-2.7 14-6 20.3V76a16.3 16.3 0 0 1 15.9-4.8c1.4.4 2.7 1 4 1.7l.1-.7a59 59 0 0 1 9.7-4.3l-.2-.6a16 16 0 0 0-3-10.3v-.9Z"/><path fill="#fff" fill-opacity=".5" d="M137.4 6.9h-.1a63 63 0 0 1 .9 18.1l.2.7 5.7-2-.4-1a31.3 31.3 0 0 0-6.3-15.8Zm-20.7 8.2a3.6 3.6 0 1 0 0 7.2 3.6 3.6 0 0 0 0-7.2ZM6.2 82.5a3.8 3.8 0 1 0 0 7.6 3.8 3.8 0 0 0 0-7.6Z"/><path fill="#000" fill-opacity=".2" d="M26.6 74.3A18 18 0 0 1 39 62.2l-.2-.7c-1.6.4-3.2 1-5 1.6A66.7 66.7 0 0 0 8.3 34.8 145 145 0 0 1 28 69c-.8 1.5-1.5 3.3-1.8 5.1h.3Z"/><path fill="#fff" fill-opacity=".5" d="M39 62.2a18 18 0 0 0-12.4 12h-.3a25 25 0 0 0-.4 7.8c-4.5-4-9.5-7.6-15.3-10.3 3 5.2 13 18.7 16.2 24.1l2.3-1.3 2.4-1s-6.1-9.2-4-11a44 44 0 0 0 12.3-18.6l2-5.6-.3-.2-1.6 3.1c-.4 0-.7.2-1 .3l.1.7Z"/><path fill="#fff" fill-opacity=".5" d="M69.9 39.5c1.8-2.3 4.3-4 7-5l-.3-.7-1.2.5a28 28 0 0 0-3.6-11l-10 .1 2.5-8.7a29 29 0 0 0-14-7.4c-5.3-.9-11.1.7-14.5 4.9A19.2 19.2 0 0 0 32.5 24a46.6 46.6 0 0 0 10.9 30c-.6 1.3-1.2 2.7-2 4.1l.5.2c.8-1.8 1.8-3.5 3.2-4.8a9.7 9.7 0 0 1 15.2 2.9h.3a44.6 44.6 0 0 1 9-17.2l.3.3Z"/><path fill="#fff" fill-opacity=".5" d="M96.3 30.8c-6.6-.5-13.4.5-19.7 3l.3.7c2.3-1 5-1.5 7.5-1.6a44 44 0 0 1 17 3.4c12.5 4.7 24.1 11.4 36.7 15.8a60 60 0 0 0 26.8 4c4.2-.4 8.3-1.3 12.2-3l.1.2a55.6 55.6 0 0 0 17.3-13.1c.9-1 1.8-2.2 2.1-3.6.5-2.3-.8-4.7-2.5-6.5-3.6-4-8.7-6.6-14.2-6.7-5.8 2.7-11.8 5.1-17.6 7.5 0-3.3-.2-6.6 0-10-6.2-.6-12.3.7-18.2 2.7l-5.7 2-2.1 1c-8.4 3.3-16.8 7-25.8 7.6a46 46 0 0 0-14.2-3.4Z"/><path class="shamanColor2" d="m131.8 63-4.2 4.4a93.2 93.2 0 0 0 5.8 3.2l2-5.2.9-5.2-4.5 2.9Z"/><path fill="#000" fill-opacity=".2" d="m131.8 63-4.2 4.4 3 1.6 2.8 1.6 2-5.2.9-5.2-4.5 2.9Z"/><path class="hwStr1" stroke-width="4" d="M96.3 30.8a46 46 0 0 1 14.2 3.4c9-.6 17.4-4.3 25.8-7.7l2.1-.8 5.7-2c6-2 12-3.4 18.3-2.9a116 116 0 0 0-.1 10c5.8-2.3 11.8-4.7 17.6-7.4 5.5.1 10.6 2.7 14.2 6.7 1.7 1.8 3 4.2 2.5 6.5a8.4 8.4 0 0 1-2.1 3.6 55.6 55.6 0 0 1-28 17l1.6 3.2c8.2-.3 16.2-1.9 23.8-4.8-5 4.8-11.2 8.2-17.7 10m0 0-1.2.4a41.4 41.4 0 0 1 1.2-.3Zm0 0a44 44 0 0 1 26.4 3.3 34 34 0 0 1 19 24.4 37.1 37.1 0 0 0-43-19.7h-.3l1.6.8a30 30 0 0 1 17 21.7c-2.3 0-4.6.1-7.2.7 1.4 7.5-.1 15.6-5 22.6-2.5-1-5-1.8-8.2-2a34 34 0 0 1 2 12.2 37.9 37.9 0 0 1-6.7 6 14.2 14.2 0 0 1-8.5 2.7c-3.9-.2-7.4-2.5-9.8-5.5-2.5-3-4-6.6-5.9-10.3 1-3.3 3-6.4 5.3-8.8-3.3-.1-6.5-.3-9.6-.1a61 61 0 0 0 .8-30.6"/><path class="hwStr1" stroke-width="4" d="M27.5 96.5C17.8 105 15 113.7 18.2 124a17 17 0 0 1-9-17.5c1-6.8 11.4-9 18.3-10Zm0 0S13.7 76.9 10.6 71.7c5.8 2.7 10.9 5 15.3 10.3a25 25 0 0 1 2.2-12.9c-5-12.5-11.7-24-19.8-34.3A66.7 66.7 0 0 1 33.8 63c1.8-.6 3.4-1.2 5-1.6l1.1-.3a54 54 0 0 0 3.5-7.2 46.6 46.6 0 0 1-10.9-30c0-4.1.8-8.5 3.3-11.8 3.4-4.2 9.2-5.8 14.5-5a29 29 0 0 1 14 7.5L62 23.4h10c2 3.4 3.1 7 3.5 10.9a44.4 44.4 0 0 1 21-3.5"/><path class="hwStr1" stroke-width="4" d="M74.4 100.3a50.8 50.8 0 0 1-12.9-18.9 43 43 0 0 1 8.1-42.2c1.5-1.7 3.1-3.3 4.9-4.8M64.4 88.3 60 94.4m.6-15.6-8.5 13m72.4-24c6.3-6.1 11.5-11 20-13.3M166 82.6a7.4 7.4 0 0 1 2.4-8.3 8.9 8.9 0 0 1 9.5 0"/><path class="hwStr1" stroke-width="4" d="M138.5 76a16.3 16.3 0 0 1 15.8-4.8A17 17 0 0 1 165.8 82"/><path class="hwStr1" stroke-width="3" d="M177.1 53.1c-4 1.7-8 2.6-12.2 3a60 60 0 0 1-26.8-4c-12.6-4.4-24.2-11-36.7-15.8a44 44 0 0 0-17-3.4 21 21 0 0 0-7.5 1.6 17.5 17.5 0 0 0-7.7 5.9m26.5-9.8.6.2h0c8.8 3 17.6 6 26.7 7 9.4 1 19.3-.1 27.4-5.1m17 72a94 94 0 0 0-.5-14.6c-.4-3.1-1-6.2-2-9a14.5 14.5 0 0 0-5.9-7m8.4 30.7a125 125 0 0 1 0 0Zm0 0v-.1"/><path class="hwStr1" stroke-width="3" d="M166.3 77c1.3 9.3 1.6 18.6 1 27.7m11.3-4.8-3.3-3M182 89c-1.9-1.5-4-2.7-6.3-3.5m-16.8 9.3-5.6 3m4.5-16.2a15 15 0 0 0-7.4 2.6m8-12a59 59 0 0 1 14.8-5.7m-5.2.8a18 18 0 0 0-3-10.3m-11.3 7.6A33 33 0 0 0 138.4 76v.1a53.3 53.3 0 0 0 6-20.3m-10.8 17.4a82 82 0 0 0 4.9-16.2m5.2-34.4A31.3 31.3 0 0 0 137.4 7l-.2-.2m1 18.2a63 63 0 0 0-1-18M105 66a48.6 48.6 0 0 1 14.9-21M81.5 78.3a56.4 56.4 0 0 1 9-45m-28 16.8a395.3 395.3 0 0 1-14.7-27m17.7 8-2 4.1m-2.9-7L59.2 31m-8.5 13.2-5.4.7m2-6.8-5-.6M27.5 82.4A44.3 44.3 0 0 0 39.8 64l2-5.6c.9-1.8 1.9-3.5 3.3-4.8a9.7 9.7 0 0 1 15.2 2.9m-32.7 26c5.1-2.1 10.9-2 16.5-2.4 2-.2 4.2-.4 6.3-1 3.4-.8 6.6-2.2 9-4.7"/><path class="hwStr1" stroke-width="4" d="M44.2 92c-1.5-3.8-2.6-6.8-4.4-11"/><path class="hwStr1" stroke-width="3" d="M26.6 74.3A18 18 0 0 1 39 62.2"/><path class="hwStr1" stroke-width="4" d="M31.8 82.6 35.2 93"/><path class="hwStr1" stroke-width="3" d="M33.2 93.5a122 122 0 0 0-8-11.8m151.6-68.9a3.7 3.7 0 1 1 0-7.4 3.7 3.7 0 0 1 0 7.4Zm34.6 46.5a5.1 5.1 0 1 1 0-10.3 5.1 5.1 0 0 1 0 10.3Zm-91.1-40.6a3.6 3.6 0 1 0-7.1 0 3.6 3.6 0 0 0 7.1 0ZM10 86.3a3.8 3.8 0 1 0-7.6 0 3.8 3.8 0 0 0 7.6 0Z"/><path class="shamanColor1" d="M78.8 59.6c2.6-1.7 6.2-.6 8.3 1.6 2.2 2.2 3.2 5.2 4.1 8.1.3 0 .5-.2.8-.3a55 55 0 0 0-6 14.8c-1.9.7-3 1.5-4.3 2-1.4.5-3 .5-4.4-.2a4.7 4.7 0 0 1-2.3-4.1 7 7 0 0 1 1.8-4.5c1.1-1.2 2.5-2.1 4-2.9-2-2.2-3.7-4.5-4.3-7.2-.7-2.6 0-5.8 2.3-7.3Z"/><path class="shamanColor1" d="M98.7 67.1a7 7 0 0 1 6.4 2.9c1.5 2.4.6 5.9-1.6 7.9a11 11 0 0 1-8 2.5c0 2 .6 3.8.3 5.7-.2 1.8-1.4 3.6-3.2 4-1.6.2-3.3-.7-4.2-2-1-1.3-1.4-3-1.9-4.5l-.6.2A55 55 0 0 1 92 69c2.5-.8 4.5-1.7 6.8-1.9Z"/><path class="hwStr1" stroke-width="4" d="m85.4 86.3.5-2.5A55 55 0 0 1 93 67.3"/><path class="hwStr1" stroke-width="3.5" d="m92 69-.8.3c-1-2.9-2-6-4-8.1-2.2-2.2-5.8-3.3-8.4-1.6-2.3 1.5-3 4.7-2.3 7.3.6 2.7 2.3 5 4.3 7.2-1.5.8-2.9 1.7-4 3a7 7 0 0 0-1.8 4.4c0 1.6.8 3.3 2.3 4.1 1.3.7 3 .7 4.4.1 1.3-.4 2.4-1.2 4.2-1.9l.6-.2c.5 1.6 1 3.2 1.9 4.5 1 1.3 2.6 2.2 4.2 2 1.8-.4 3-2.2 3.2-4 .3-1.9-.2-3.7-.4-5.7 3 0 6-.6 8.1-2.5 2.2-2 3-5.5 1.6-8-1.3-2-4-3-6.4-2.8-2.3.2-4.3 1.1-6.7 2Z"/><path class="hwStr1" stroke-width="3" d="m90.6 57.7 1.7 9.6m7.7-6.6-7.1 6.2"/></svg>'
            ),
            Headwear.HeadwearVariants.SHAMAN,
            _getHeadwearColor(shamanColor)
        );
    }

    function _getShamanStyle(ShamanColors shamanColor) internal pure returns (string memory) {
        (string memory primaryColor, string memory secondaryColor) = _getShamanColor(shamanColor);
        return
            string.concat(
                '<style>.shamanColor1 { fill:',
                primaryColor,
                '}.shamanColor2 { fill:',
                secondaryColor,
                '}.hwStr1 {stroke: #000;stroke-linecap: round;stroke-linejoin: round;}</style>'
            );
    }

    function _getShamanColor(ShamanColors shamanColor) internal pure returns (string memory, string memory) {
        if (shamanColor == ShamanColors.GREEN) {
            return (EduxColors.lightGreen, EduxColors.baseGreen);
        } else if (shamanColor == ShamanColors.PURPLE) {
            return (EduxColors.lightPurple, EduxColors.basePurple);
        } else if (shamanColor == ShamanColors.BLUE) {
            return (EduxColors.lightBlue, EduxColors.baseBlue);
        } else if (shamanColor == ShamanColors.PINK) {
            return (EduxColors.lightPink, EduxColors.basePink);
        } else if (shamanColor == ShamanColors.GOLD) {
            return (EduxColors.lightGold, EduxColors.baseGold);
        } else {
            revert(); // Avoid warnings.
        }
    }

    function _getHeadwearColor(ShamanColors shamanColor) internal pure returns (Headwear.HeadwearColors) {
        if (shamanColor == ShamanColors.GREEN) {
            return Headwear.HeadwearColors.GREEN;
        } else if (shamanColor == ShamanColors.PURPLE) {
            return Headwear.HeadwearColors.PURPLE;
        } else if (shamanColor == ShamanColors.BLUE) {
            return Headwear.HeadwearColors.BLUE;
        } else if (shamanColor == ShamanColors.PINK) {
            return Headwear.HeadwearColors.PINK;
        } else if (shamanColor == ShamanColors.GOLD) {
            return Headwear.HeadwearColors.GOLD;
        } else {
            revert(); // Avoid warnings.
        }
    }
}
