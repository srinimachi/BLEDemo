# Bluetooth Widget Demo

This repository contains a Swift project featuring a single screen displaying a label indicating the current Bluetooth connection status ("Connected" or "Disconnected"). Additionally, there is a widget on the home screen that dynamically shows the time of change in the Bluetooth connection state.

## Problem Description

The primary issue involves the widget not reliably reloading when the Bluetooth connection status changes. Specifically, there are observed difficulties when the app is built and run using a profile build. While running in the foreground during a profile build, the widget reloads as expected. However, when the app enters the background, the widget may not reload correctly.
